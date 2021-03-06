#version 150

struct Globals
{
    mat4 ViewProjection;
    vec4 ViewRight;
    vec4 ViewUp;
    vec4 ViewDir;
    vec3 CameraPosition;
    vec3 AmbientColor;
    vec3 SkyAmbient;
    vec3 Lamp0Color;
    vec3 Lamp0Dir;
    vec3 Lamp1Color;
    vec4 FogParams;
    vec4 FogColor_GlobalForceFieldTime;
    vec3 Exposure;
    vec4 LightConfig0;
    vec4 LightConfig1;
    vec4 LightConfig2;
    vec4 LightConfig3;
    vec4 ShadowMatrix0;
    vec4 ShadowMatrix1;
    vec4 ShadowMatrix2;
    vec4 RefractionBias_FadeDistance_GlowFactor_SpecMul;
    vec4 OutlineBrightness_ShadowInfo;
    vec4 SkyGradientTop_EnvDiffuse;
    vec4 SkyGradientBottom_EnvSpec;
    vec3 AmbientColorNoIBL;
    vec3 SkyAmbientNoIBL;
    vec4 AmbientCube[12];
    vec4 CascadeSphere0;
    vec4 CascadeSphere1;
    vec4 CascadeSphere2;
    vec4 CascadeSphere3;
    float hybridLerpDist;
    float hybridLerpSlope;
    float evsmPosExp;
    float evsmNegExp;
    float globalShadow;
    float shadowBias;
    float shadowAlphaRef;
    float debugFlags;
};

uniform vec4 CB0[47];
uniform sampler2D ShadowMapTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform sampler2D DiffuseMapTexture;

in vec4 VARYING0;
in vec4 VARYING2;
in vec3 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
out vec4 _entryPointOutput;

void main()
{
    vec4 f0 = texture(DiffuseMapTexture, VARYING0.xy) * VARYING2;
    vec3 f1 = f0.xyz;
    float f2 = clamp(dot(step(CB0[19].xyz, abs(VARYING3 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f3 = VARYING3.yzx - (VARYING3.yzx * f2);
    vec4 f4 = vec4(clamp(f2, 0.0, 1.0));
    vec4 f5 = mix(texture(LightMapTexture, f3), vec4(0.0), f4);
    vec4 f6 = mix(texture(LightGridSkylightTexture, f3), vec4(1.0), f4);
    vec4 f7 = texture(ShadowMapTexture, VARYING6.xy);
    float f8 = (1.0 - ((step(f7.x, VARYING6.z) * clamp(CB0[24].z + (CB0[24].w * abs(VARYING6.z - 0.5)), 0.0, 1.0)) * f7.y)) * f6.y;
    vec3 f9 = (f1 * f1).xyz;
    float f10 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    vec3 f11 = normalize(VARYING5.xyz);
    float f12 = max(VARYING5.w, 0.04500000178813934326171875);
    float f13 = VARYING6.w * f10;
    vec3 f14 = -CB0[11].xyz;
    vec3 f15 = normalize(f14 + normalize(VARYING4.xyz));
    float f16 = dot(f11, f14);
    float f17 = clamp(f16, 0.0, 1.0);
    float f18 = f12 * f12;
    float f19 = max(0.001000000047497451305389404296875, dot(f11, f15));
    float f20 = dot(f14, f15);
    float f21 = 1.0 - f20;
    float f22 = f21 * f21;
    float f23 = (f22 * f22) * f21;
    vec3 f24 = vec3(f23) + (mix(vec3(0.039999999105930328369140625), f9, vec3(f13)) * (1.0 - f23));
    float f25 = f18 * f18;
    float f26 = (((f19 * f25) - f19) * f19) + 1.0;
    float f27 = 1.0 - f13;
    vec3 f28 = ((((((((vec3(1.0) - (f24 * f10)) * f27) * CB0[10].xyz) * f17) + ((CB0[12].xyz * f27) * clamp(-f16, 0.0, 1.0))) * f8) + min((f5.xyz * (f5.w * 120.0)).xyz + (CB0[8].xyz + (CB0[9].xyz * f6.x)), vec3(CB0[16].w))) * f9) + ((((f24 * ((f25 + (f25 * f25)) / (((f26 * f26) * ((f20 * 3.0) + 0.5)) * ((f19 * 0.75) + 0.25)))) * CB0[10].xyz) * f17) * f8);
    vec4 f29 = vec4(f28.x, f28.y, f28.z, vec4(0.0).w);
    f29.w = f0.w;
    vec3 f30 = mix(CB0[14].xyz, (sqrt(clamp(f29.xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))))).xyz, vec3(clamp((CB0[13].x * length(VARYING4.xyz)) + CB0[13].y, 0.0, 1.0)));
    _entryPointOutput = vec4(f30.x, f30.y, f30.z, f29.w);
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$DiffuseMapTexture=s3
