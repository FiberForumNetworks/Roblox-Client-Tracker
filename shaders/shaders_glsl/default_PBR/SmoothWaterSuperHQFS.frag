#version 110

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

struct Params
{
    vec4 WaveParams;
    vec4 WaterColor;
    vec4 WaterParams;
};

uniform vec4 CB0[47];
uniform vec4 CB3[3];
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform sampler2D NormalMap1Texture;
uniform sampler2D NormalMap2Texture;
uniform sampler2D GBufferDepthTexture;
uniform sampler2D GBufferColorTexture;
uniform samplerCube EnvMapTexture;

varying vec4 VARYING0;
varying vec3 VARYING1;
varying vec2 VARYING2;
varying vec2 VARYING3;
varying vec2 VARYING4;
varying vec3 VARYING5;
varying vec4 VARYING6;
varying vec4 VARYING7;
varying vec4 VARYING8;

void main()
{
    float f0 = clamp(dot(step(CB0[19].xyz, abs(VARYING5 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f1 = VARYING5.yzx - (VARYING5.yzx * f0);
    vec4 f2 = vec4(clamp(f0, 0.0, 1.0));
    vec4 f3 = mix(texture3D(LightMapTexture, f1), vec4(0.0), f2);
    vec4 f4 = mix(texture3D(LightGridSkylightTexture, f1), vec4(1.0), f2);
    vec3 f5 = (f3.xyz * (f3.w * 120.0)).xyz;
    float f6 = f4.x;
    float f7 = f4.y;
    vec4 f8 = vec4(CB3[0].w);
    float f9 = -VARYING6.x;
    vec4 f10 = ((mix(texture2D(NormalMap1Texture, VARYING2), texture2D(NormalMap2Texture, VARYING2), f8) * VARYING0.x) + (mix(texture2D(NormalMap1Texture, VARYING3), texture2D(NormalMap2Texture, VARYING3), f8) * VARYING0.y)) + (mix(texture2D(NormalMap1Texture, VARYING4), texture2D(NormalMap2Texture, VARYING4), f8) * VARYING0.z);
    vec2 f11 = f10.wy * 2.0;
    vec2 f12 = f11 - vec2(1.0);
    float f13 = f10.x;
    vec3 f14 = vec3(dot(VARYING1, VARYING0.xyz));
    vec4 f15 = vec4(normalize(((mix(vec3(VARYING6.z, 0.0, f9), vec3(VARYING6.y, f9, 0.0), f14) * f12.x) + (mix(vec3(0.0, -1.0, 0.0), vec3(0.0, -VARYING6.z, VARYING6.y), f14) * f12.y)) + (VARYING6.xyz * sqrt(clamp(1.0 + dot(vec2(1.0) - f11, f12), 0.0, 1.0)))), f13);
    vec3 f16 = f15.xyz;
    vec3 f17 = mix(VARYING6.xyz, f16, vec3(0.25));
    vec3 f18 = normalize(VARYING7.xyz);
    vec3 f19 = f16 * f16;
    bvec3 f20 = lessThan(f16, vec3(0.0));
    vec3 f21 = vec3(f20.x ? f19.x : vec3(0.0).x, f20.y ? f19.y : vec3(0.0).y, f20.z ? f19.z : vec3(0.0).z);
    vec3 f22 = f19 - f21;
    float f23 = f22.x;
    float f24 = f22.y;
    float f25 = f22.z;
    float f26 = f21.x;
    float f27 = f21.y;
    float f28 = f21.z;
    vec2 f29 = VARYING8.xy / vec2(VARYING8.w);
    vec2 f30 = f29 + (f15.xz * 0.0500000007450580596923828125);
    vec4 f31 = texture2D(GBufferColorTexture, f29);
    f31.w = texture2D(GBufferDepthTexture, f29).x * 500.0;
    float f32 = texture2D(GBufferDepthTexture, f30).x * 500.0;
    vec4 f33 = texture2D(GBufferColorTexture, f30);
    f33.w = f32;
    vec4 f34 = mix(f31, f33, vec4(clamp(f32 - VARYING8.w, 0.0, 1.0)));
    vec3 f35 = f34.xyz;
    vec3 f36 = reflect(-f18, f17);
    float f37 = VARYING8.w * 0.20000000298023223876953125;
    vec4 f38 = vec4(f36, 0.0) * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    float f39 = f38.w;
    vec2 f40 = (f38.xy * 0.5) + vec2(0.5 * f39);
    vec4 f41 = vec4(f40.x, f40.y, f38.z, f38.w);
    float f42 = 1.0 + clamp(0.0, VARYING8.w * (-0.20000000298023223876953125), f37);
    vec4 f43 = VARYING8 + (f41 * f42);
    float f44 = f43.w;
    float f45 = f42 + clamp((texture2D(GBufferDepthTexture, f43.xy / vec2(f44)).x * 500.0) - f44, VARYING8.w * (-0.20000000298023223876953125), f37);
    vec4 f46 = VARYING8 + (f41 * f45);
    float f47 = f46.w;
    float f48 = f45 + clamp((texture2D(GBufferDepthTexture, f46.xy / vec2(f47)).x * 500.0) - f47, VARYING8.w * (-0.20000000298023223876953125), f37);
    vec4 f49 = VARYING8 + (f41 * f48);
    float f50 = f49.w;
    float f51 = f48 + clamp((texture2D(GBufferDepthTexture, f49.xy / vec2(f50)).x * 500.0) - f50, VARYING8.w * (-0.20000000298023223876953125), f37);
    vec4 f52 = VARYING8 + (f41 * f51);
    float f53 = f52.w;
    float f54 = f51 + clamp((texture2D(GBufferDepthTexture, f52.xy / vec2(f53)).x * 500.0) - f53, VARYING8.w * (-0.20000000298023223876953125), f37);
    vec4 f55 = VARYING8 + (f41 * f54);
    float f56 = f55.w;
    float f57 = f54 + clamp((texture2D(GBufferDepthTexture, f55.xy / vec2(f56)).x * 500.0) - f56, VARYING8.w * (-0.20000000298023223876953125), f37);
    vec4 f58 = VARYING8 + (f41 * f57);
    float f59 = f58.w;
    float f60 = f57 + clamp((texture2D(GBufferDepthTexture, f58.xy / vec2(f59)).x * 500.0) - f59, VARYING8.w * (-0.20000000298023223876953125), f37);
    vec4 f61 = VARYING8 + (f41 * f60);
    float f62 = f61.w;
    float f63 = f60 + clamp((texture2D(GBufferDepthTexture, f61.xy / vec2(f62)).x * 500.0) - f62, VARYING8.w * (-0.20000000298023223876953125), f37);
    vec4 f64 = VARYING8 + (f41 * f63);
    float f65 = f64.w;
    vec4 f66 = VARYING8 + (f41 * f63);
    float f67 = f66.w;
    vec2 f68 = f66.xy / vec2(f67);
    vec3 f69 = textureCube(EnvMapTexture, f36).xyz;
    vec3 f70 = texture2D(GBufferColorTexture, f68).xyz;
    vec3 f71 = -CB0[11].xyz;
    vec3 f72 = normalize(f71 + f18);
    float f73 = f13 * f13;
    float f74 = max(0.001000000047497451305389404296875, dot(f16, f72));
    float f75 = dot(f71, f72);
    float f76 = 1.0 - f75;
    float f77 = f76 * f76;
    float f78 = (f77 * f77) * f76;
    float f79 = f73 * f73;
    float f80 = (((f74 * f79) - f74) * f74) + 1.0;
    vec3 f81 = mix(mix(((f35 * f35) * CB0[15].x).xyz, ((min(f5 + (CB0[27].xyz + (CB0[28].xyz * f6)), vec3(CB0[16].w)) + (((((((CB0[35].xyz * f23) + (CB0[37].xyz * f24)) + (CB0[39].xyz * f25)) + (CB0[36].xyz * f26)) + (CB0[38].xyz * f27)) + (CB0[40].xyz * f28)) + (((((((CB0[29].xyz * f23) + (CB0[31].xyz * f24)) + (CB0[33].xyz * f25)) + (CB0[30].xyz * f26)) + (CB0[32].xyz * f27)) + (CB0[34].xyz * f28)) * f6))) + (CB0[10].xyz * f7)) * CB3[1].xyz, vec3(clamp(clamp(((f34.w - VARYING8.w) * CB3[2].x) + CB3[2].y, 0.0, 1.0) + clamp((VARYING8.w * 0.0040000001899898052215576171875) - 1.0, 0.0, 1.0), 0.0, 1.0))), mix(((f69 * f69) * CB0[15].x) * f6, (f70 * f70) * CB0[15].x, vec3((((float(abs(f68.x - 0.5) < 0.550000011920928955078125) * float(abs(f68.y - 0.5) < 0.5)) * clamp(3.900000095367431640625 - (max(VARYING8.w, f67) * 0.008000000379979610443115234375), 0.0, 1.0)) * float(abs((texture2D(GBufferDepthTexture, f64.xy / vec2(f65)).x * 500.0) - f65) < 10.0)) * float(f39 > 0.0))) + (f5 * 0.100000001490116119384765625), vec3(((clamp(0.7799999713897705078125 - (2.5 * abs(dot(f17, f18))), 0.0, 1.0) + 0.300000011920928955078125) * VARYING0.w) * CB3[2].z)) + ((((((vec3(f78) + (vec3(0.0199999995529651641845703125) * (1.0 - f78))) * ((f79 + (f79 * f79)) / (((f80 * f80) * ((f75 * 3.0) + 0.5)) * ((f74 * 0.75) + 0.25)))) * CB0[10].xyz) * clamp(dot(f16, f71), 0.0, 1.0)) * f7) * clamp(1.0 - (VARYING7.w * CB0[23].y), 0.0, 1.0));
    vec4 f82 = vec4(f81.x, f81.y, f81.z, vec4(0.0).w);
    f82.w = 1.0;
    vec3 f83 = mix(CB0[14].xyz, sqrt(clamp(f82.xyz * CB0[15].y, vec3(0.0), vec3(1.0))).xyz, vec3(clamp(VARYING6.w, 0.0, 1.0)));
    gl_FragData[0] = vec4(f83.x, f83.y, f83.z, f82.w);
}

//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$NormalMap1Texture=s0
//$$NormalMap2Texture=s2
//$$GBufferDepthTexture=s5
//$$GBufferColorTexture=s4
//$$EnvMapTexture=s3
