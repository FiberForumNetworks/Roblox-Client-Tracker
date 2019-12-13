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

struct LightShadowGPUTransform
{
    mat4 transform;
};

struct MaterialParams
{
    float textureTiling;
    float specularScale;
    float glossScale;
    float reflectionScale;
    float normalShadowScale;
    float specularLod;
    float glossLod;
    float normalDetailTiling;
    float normalDetailScale;
    float farTilingDiffuse;
    float farTilingNormal;
    float farTilingSpecular;
    float farDiffuseCutoff;
    float farNormalCutoff;
    float farSpecularCutoff;
    float optBlendColorK;
    float farDiffuseCutoffScale;
    float farNormalCutoffScale;
    float farSpecularCutoffScale;
    float isNonSmoothPlastic;
};

uniform vec4 CB0[47];
uniform vec4 CB8[24];
uniform vec4 CB2[5];
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform sampler2D ShadowAtlasTexture;
uniform sampler2D DiffuseMapTexture;
uniform sampler2D NormalMapTexture;
uniform sampler2D NormalDetailMapTexture;
uniform sampler2D StudsMapTexture;
uniform sampler2D SpecularMapTexture;
uniform sampler2D GBufferDepthTexture;
uniform sampler2D GBufferColorTexture;
uniform samplerCube EnvironmentMapTexture;

in vec4 VARYING0;
in vec4 VARYING1;
in vec4 VARYING2;
in vec3 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
in vec4 VARYING7;
in float VARYING8;
out vec4 _entryPointOutput;

void main()
{
    vec2 f0 = VARYING1.xy;
    f0.y = (fract(VARYING1.y) + VARYING8) * 0.25;
    float f1 = clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    vec2 f2 = VARYING0.xy * CB2[0].x;
    vec4 f3 = texture(DiffuseMapTexture, f2);
    vec2 f4 = texture(NormalMapTexture, f2).wy * 2.0;
    vec2 f5 = f4 - vec2(1.0);
    float f6 = sqrt(clamp(1.0 + dot(vec2(1.0) - f4, f5), 0.0, 1.0));
    vec2 f7 = (vec3(f5, f6).xy + (vec3((texture(NormalDetailMapTexture, f2 * CB2[1].w).wy * 2.0) - vec2(1.0), 0.0).xy * CB2[2].x)).xy * f1;
    float f8 = f7.x;
    float f9 = f3.w;
    vec4 f10 = mix(texture(SpecularMapTexture, f2 * CB2[2].w), texture(SpecularMapTexture, f2), vec4(clamp((f1 * CB2[4].z) - (CB2[3].z * CB2[4].z), 0.0, 1.0)));
    vec2 f11 = mix(vec2(CB2[1].y, CB2[1].z), (f10.xy * vec2(CB2[0].y, CB2[0].z)) + vec2(0.0, 0.00999999977648258209228515625), vec2(f1));
    float f12 = VARYING2.w * 2.0;
    float f13 = clamp(f12, 0.0, 1.0);
    vec3 f14 = vec4(((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f9 + CB2[3].w, 0.0, 1.0))) * f3.xyz) * (1.0 + (f8 * CB2[1].x))) * (texture(StudsMapTexture, f0).x * 2.0), f9).xyz;
    vec3 f15 = normalize(((VARYING6.xyz * f8) + (cross(VARYING5.xyz, VARYING6.xyz) * f7.y)) + (VARYING5.xyz * (f6 * 10.0)));
    vec3 f16 = -CB0[11].xyz;
    float f17 = dot(f15, f16);
    float f18 = clamp(dot(step(CB0[19].xyz, abs(VARYING3 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f19 = VARYING3.yzx - (VARYING3.yzx * f18);
    vec4 f20 = vec4(clamp(f18, 0.0, 1.0));
    vec4 f21 = mix(texture(LightMapTexture, f19), vec4(0.0), f20);
    vec4 f22 = mix(texture(LightGridSkylightTexture, f19), vec4(1.0), f20);
    vec3 f23 = (f21.xyz * (f21.w * 120.0)).xyz;
    float f24 = f22.x;
    float f25 = f22.y;
    vec3 f26 = VARYING7.xyz - CB0[41].xyz;
    vec3 f27 = VARYING7.xyz - CB0[42].xyz;
    vec3 f28 = VARYING7.xyz - CB0[43].xyz;
    vec4 f29 = vec4(VARYING7.xyz, 1.0) * mat4(CB8[((dot(f26, f26) < CB0[41].w) ? 0 : ((dot(f27, f27) < CB0[42].w) ? 1 : ((dot(f28, f28) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f26, f26) < CB0[41].w) ? 0 : ((dot(f27, f27) < CB0[42].w) ? 1 : ((dot(f28, f28) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f26, f26) < CB0[41].w) ? 0 : ((dot(f27, f27) < CB0[42].w) ? 1 : ((dot(f28, f28) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f26, f26) < CB0[41].w) ? 0 : ((dot(f27, f27) < CB0[42].w) ? 1 : ((dot(f28, f28) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f30 = textureLod(ShadowAtlasTexture, f29.xy, 0.0);
    vec2 f31 = vec2(0.0);
    f31.x = CB0[45].z;
    vec2 f32 = f31;
    f32.y = CB0[45].w;
    float f33 = (2.0 * f29.z) - 1.0;
    float f34 = exp(CB0[45].z * f33);
    float f35 = -exp((-CB0[45].w) * f33);
    vec2 f36 = (f32 * CB0[46].y) * vec2(f34, f35);
    vec2 f37 = f36 * f36;
    float f38 = f30.x;
    float f39 = max(f30.y - (f38 * f38), f37.x);
    float f40 = f34 - f38;
    float f41 = f30.z;
    float f42 = max(f30.w - (f41 * f41), f37.y);
    float f43 = f35 - f41;
    float f44 = (f17 > 0.0) ? mix(f25, mix(min((f34 <= f38) ? 1.0 : clamp(((f39 / (f39 + (f40 * f40))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f35 <= f41) ? 1.0 : clamp(((f42 / (f42 + (f43 * f43))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f25, clamp((length(VARYING7.xyz - CB0[7].xyz) * CB0[45].y) - (CB0[45].x * CB0[45].y), 0.0, 1.0)), CB0[46].x) : 0.0;
    vec3 f45 = f14 * f14;
    vec3 f46 = normalize(VARYING4.xyz);
    vec3 f47 = texture(EnvironmentMapTexture, reflect(-VARYING4.xyz, f15)).xyz;
    vec3 f48 = mix(f23, (f47 * f47) * CB0[15].x, vec3(f24)) * mix(vec3(1.0), f45, vec3(0.5));
    float f49 = 1.0 - dot(f15, f46);
    float f50 = 1.0 - VARYING2.w;
    float f51 = mix(0.660000026226043701171875, 1.0, f50 * f50);
    mat4 f52 = mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec4 f53 = vec4(CB0[7].xyz - VARYING4.xyz, 1.0) * f52;
    vec4 f54 = vec4(CB0[7].xyz - ((VARYING4.xyz * (1.0 + ((3.0 * f51) / max(dot(VARYING4.xyz, f15), 0.00999999977648258209228515625)))) + (f15 * (3.0 * (1.0 - f51)))), 1.0) * f52;
    float f55 = f53.w;
    vec2 f56 = ((f53.xy * 0.5) + vec2(0.5 * f55)).xy / vec2(f55);
    float f57 = f54.w;
    vec2 f58 = ((f54.xy * 0.5) + vec2(0.5 * f57)).xy / vec2(f57);
    vec2 f59 = f58 - vec2(0.5);
    vec2 f60 = (f58 - f56) * clamp(vec2(1.0) - ((f59 * f59) * 4.0), vec2(0.0), vec2(1.0));
    vec2 f61 = normalize(f60) * CB0[23].x;
    vec4 f62 = texture(GBufferColorTexture, f56 + (f60 * clamp(min(texture(GBufferDepthTexture, f58 + f61).x * 500.0, texture(GBufferDepthTexture, f58 - f61).x * 500.0) - f55, 0.0, 1.0)));
    vec3 f63 = f62.xyz;
    vec3 f64 = ((f63 * f63) * CB0[15].x).xyz;
    vec3 f65 = f64 * mix(vec3(1.0), VARYING2.xyz, vec3(f13));
    vec4 f66 = vec4(f65.x, f65.y, f65.z, vec4(0.0).w);
    f66.w = mix(1.0, f62.w, dot(f65.xyz, vec3(1.0)) / (dot(f64, vec3(1.0)) + 0.00999999977648258209228515625));
    vec4 f67 = mix(mix(f66, vec4(mix((min(f23 + (CB0[8].xyz + (CB0[9].xyz * f24)), vec3(CB0[16].w)) + (((CB0[10].xyz * clamp(f17, 0.0, 1.0)) + (CB0[12].xyz * max(-f17, 0.0))) * f44)) * f45, f48, vec3(mix((f10.y * f1) * CB2[0].w, 1.0, VARYING7.w))), 1.0), vec4(clamp((f12 - 1.0) + f9, 0.0, 1.0))), vec4(f48, 1.0), vec4(((f49 * f49) * 0.800000011920928955078125) * f13)) + vec4(CB0[10].xyz * ((((step(0.0, f17) * mix(f11.x, CB2[0].y, VARYING7.w)) * f44) * pow(clamp(dot(f15, normalize(f16 + f46)), 0.0, 1.0), mix(f11.y, CB2[0].z, VARYING7.w))) * f13), 0.0);
    float f68 = clamp((CB0[13].x * length(VARYING4.xyz)) + CB0[13].y, 0.0, 1.0);
    vec3 f69 = mix(CB0[14].xyz, sqrt(clamp(f67.xyz * CB0[15].y, vec3(0.0), vec3(1.0))).xyz, vec3(f68));
    vec4 f70 = vec4(f69.x, f69.y, f69.z, f67.w);
    f70.w = mix(1.0, f67.w, f68);
    _entryPointOutput = f70;
}

//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$ShadowAtlasTexture=s1
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
//$$StudsMapTexture=s0
//$$SpecularMapTexture=s5
//$$GBufferDepthTexture=s10
//$$GBufferColorTexture=s9
//$$EnvironmentMapTexture=s2
