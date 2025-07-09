// GLSL version (e.g., for WebGL)
#ifdef GL_ES
#endif

uniform vec2 r;             // 解像度情報 (r.x = width, r.y = height)
uniform vec2 ps;
uniform float u_time;       // 時間 (秒)
uniform sampler2D tex;

/**
 * @brief 2次元ベクトルから擬似乱数を生成するハッシュ関数
 * @param st 入力となる2次元ベクトル
 * @return 0.0から1.0の範囲の擬似乱数値
 * @note この種のハッシュ関数は、プロシージャルテクスチャ生成において広く利用される技術である。
 * 参考文献: The Book of Shaders by Patricio Gonzalez Vivo & Jen Lowe.
 */
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    // スクリーン解像度とUV座標を取得
    vec2 resolution = r.xy;
    vec2 uv = gl_FragCoord.xy/resolution.xy;
    uv.y = 1.0-uv.y;
    float p = mix(ps.x,ps.y,step(0.5, uv.x));
    float s = pow(2.0,p)-1.0;
    // --- グリッチエフェクトのパラメータ設定 ---
    float blockGlitchIntensity = 0.05*s;      // ブロックノイズの最大オフセット強度
    float lineGlitchIntensity = 0.08*s;       // スキャンラインの最大オフセット強度

    // 時間に基づき、グリッチを断続的に発生させるためのトリガー
    // u_timeをシードとした乱数が特定の値を超えた場合にグリッチを発生させる
    float largeGlitchTrigger = pow(step(mix(1.0,0.8,s)*step(p,0.99), random(vec2(u_time * 0.1))), 2.0);
    float smallGlitchTrigger = step(mix(1.0,0.8,s)*step(p,0.99), random(vec2(u_time * 1.5)));

    // UV座標のオフセットを初期化
    vec2 uvOffset = vec2(0.0);

    // --- 1. ブロックノイズ / 水平方向のブロックずれ ---
    // 画面をいくつかの水平ブロックに分割し、大きいグリッチトリガーが有効な場合にランダムにずらす
    if (largeGlitchTrigger > 0.0) {
        float blockY = floor(uv.y * 15.0) / 15.0;
        float blockOffset = (random(vec2(blockY, u_time * 0.2)) - 0.5) * 2.0; // -1.0 to 1.0
        uvOffset.x += blockOffset * blockGlitchIntensity * largeGlitchTrigger;
    }

    // --- 2. スキャンライン / 細かい水平線のずれ ---
    // 細かいグリッチトリガーが有効な場合に、走査線のようなノイズを発生させる
    if (smallGlitchTrigger > 0.0) {
        float lineY = floor(uv.y * resolution.y * 0.5);
        float lineOffset = (random(vec2(lineY, u_time * 5.0)) - 0.5) * 2.0; // -1.0 to 1.0
        uvOffset.x += lineOffset * lineGlitchIntensity * step(0.95, random(vec2(u_time * 2.0, lineY)));
    }

    // UV座標に全てのオフセットを適用
    vec2 finalUv = uv + uvOffset;

    // 各色チャンネルを異なるUV座標でサンプリング
    float rChannel = texture2D(tex, finalUv).r;
    float gChannel = texture2D(tex, finalUv).g;
    float bChannel = texture2D(tex, finalUv).b;
    float aChannel = texture2D(tex, uv).a; // アルファチャンネルは元のUVで取得

    // 最終的な色を合成して出力
    gl_FragColor = vec4(rChannel, gChannel, bChannel, aChannel);
}