#version 110

struct Params
{
    vec4 TextureSize;
    vec4 Params1;
    vec4 Params2;
    vec4 Params3;
    vec4 Params4;
    vec4 Params5;
    vec4 Params6;
    vec4 Bloom;
};

uniform vec4 CB1[8];
uniform sampler2D geomMapTexture;

varying vec2 VARYING0;

void main()
{
    gl_FragData[0] = vec4(min(min(texture2D(geomMapTexture, VARYING0 + (CB1[0].zw * vec2(-0.25))).x, texture2D(geomMapTexture, VARYING0 + (CB1[0].zw * vec2(0.25))).x), min(texture2D(geomMapTexture, VARYING0 + (CB1[0].zw * vec2(0.25, -0.25))).x, texture2D(geomMapTexture, VARYING0 + (CB1[0].zw * vec2(-0.25, 0.25))).x)));
}

//$$geomMapTexture=s3
