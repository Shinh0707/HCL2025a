#ifdef GL_ES
#endif

uniform vec2 r;
uniform vec2 ps;
uniform float u_time;
uniform sampler2D tex;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    vec2 resolution = r.xy;
    vec2 uv = gl_FragCoord.xy/resolution.xy;
    uv.y = 1.0-uv.y;
    float p = mix(ps.x,ps.y,step(0.5, uv.x));
    float s = p*p;
    float blockGlitchIntensity = 0.01*s;      // ブロックノイズの最大オフセット強度
    float lineGlitchIntensity = 0.02*s;       // スキャンラインの最大オフセット強度

    float largeGlitchTrigger = pow(random(vec2(u_time * 0.1 * (1.0 + p))), 2.0);
    float smallGlitchTrigger = random(vec2(u_time * 1.5 * (1.0 + p)));

    vec2 uvOffset = vec2(0.0);
    if (largeGlitchTrigger > (1.0-p)) {
        float blockY = floor(uv.y * 7.0) / 7.0;
        float blockOffset = (random(vec2(blockY, u_time * 0.2)) - 0.5) * 2.0; // -1.0 to 1.0
        uvOffset.x += blockOffset * blockGlitchIntensity * (largeGlitchTrigger-(1.0-p));
    }
    if (smallGlitchTrigger > (1.0-p)) {
        float lineY = floor(uv.y * resolution.y * 0.5);
        float lineOffset = (random(vec2(lineY, u_time * 5.0)) - 0.5) * 2.0; // -1.0 to 1.0
        uvOffset.x += lineOffset * lineGlitchIntensity * step(0.95, random(vec2(u_time * 2.0, lineY)))*p;
    }
    vec2 finalUv = uv + uvOffset;
    float rChannel = texture2D(tex, finalUv).r;
    float gChannel = texture2D(tex, finalUv).g;
    float bChannel = texture2D(tex, finalUv).b;
    float aChannel = texture2D(tex, uv).a;
    gl_FragColor = vec4(rChannel, gChannel, bChannel, aChannel);
}