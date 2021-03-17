#include "ScreenSpaceCommon.hlsl"

uniform float Gaussian_Weight[100];// = {0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216};

fixed4 Radial(sampler2D target, half2 uv, float samples, float radius, half2 center, float power)
{
    fixed4 col = 0;
    float2 dist = uv - center;
    float v1 = saturate(length(dist)/ radius);
    UNITY_UNROLL
    for(float j = 0; j < samples; j++) {
        float scale = 1 - pow((j / samples) * v1, power);
        col += tex2D(target, dist * scale + center);
        //col += tex2D(target, length(dist) < 0.1 ? uv: (dist * scale + center));
    }
    col /= samples;
    return col;
}

fixed4 DirectionalBlur(sampler2D target, float2 texelSize, float2 uv, int range, half2 dir)
{
    fixed4 color = 0;
    float v1 = 1.0 / float(range);
    UNITY_UNROLL
    for(float i = 0 ; i < 1.0; i += v1)
    {
        color += tex2D(target, uv + dir * i * texelSize);
    }
    color *= v1;
    return color;
}

fixed4 Gaussian(sampler2D target, half2 uv, fixed2 dir, float2 texelSize, int sample)
{
    fixed4 color = tex2D(target, uv) * Gaussian_Weight[0];
    UNITY_UNROLL
    for(int i = 1 ; i <= sample; i++)
    {
        color += tex2D(target, uv + dir * texelSize * i) * Gaussian_Weight[i];
        color += tex2D(target, uv + -dir * texelSize * i) * Gaussian_Weight[i];
    }

    return color;
}

fixed4 Gaussian_X(sampler2D target, half2 uv, float2 texelSize, int sample)
{
    return Gaussian(target,uv, fixed2(1, 0), texelSize, sample);
}

fixed4 Gaussian_Y(sampler2D target, half2 uv, float2 texelSize, int sample)
{
    return Gaussian(target,uv, fixed2(0, 1), texelSize, sample);
}

float _BilaterFilterFactor = 0;
half BilateralNormalWeight(float3 n1, float3 n2, int GaussianIndex)
{
    return smoothstep(_BilaterFilterFactor, 1.0, dot(n1, n2)) * Gaussian_Weight[GaussianIndex];
}

half BilateralColorWeight(fixed4 col1, fixed4 col2, int GaussianIndex)
{
    float l1 = LinearRgbToLuminance(col1.rgb);
	float l2 = LinearRgbToLuminance(col2.rgb);
	return smoothstep(_BilaterFilterFactor, 1.0, 1.0 - abs(l1 - l2)) * Gaussian_Weight[GaussianIndex];
}

half BilateralDepthWeight(float d1, float d2, float sharpness, int GaussianIndex)
{
    return exp(-abs(d1 - d2) * _ProjectionParams.z * sharpness) * Gaussian_Weight[GaussianIndex];
}

void GetWeightColor(float depth0, sampler2D target, half2 uv, fixed2 dir, float2 texelSize, float sharpness, int i, inout float totalWeight, inout fixed4 totalColor)
{
    uv = uv + dir * texelSize * i;
    fixed4 sampleColor = tex2D(target, uv);
    float3 normal;
    float depth = GetViewPosAndNormal(uv, normal);
    float weight = BilateralDepthWeight(depth, depth0, sharpness, i);
    totalWeight += weight;
    totalColor += (sampleColor * weight);
}

fixed4 BilateralDepth(sampler2D target, half2 uv, fixed2 dir, float2 texelSize, int sample, float sharpness)
{
    float totalWeight = Gaussian_Weight[0];
    fixed4 totalColor = tex2D(target, uv) * totalWeight;

    float3 _;
    float depth = GetViewPosAndNormal(uv, _);

    UNITY_UNROLL
    for(int i = 1 ; i <= sample ; i++)
    {
        GetWeightColor(depth, target, uv, dir, texelSize, sharpness, i, totalWeight, totalColor);
        GetWeightColor(depth, target, uv, -dir, texelSize, sharpness, i, totalWeight, totalColor);
    }

    totalColor /= totalWeight;
    return totalColor;
}

fixed4 BilateralDepth_X(sampler2D target, half2 uv, float2 texelSize, int sample, float sharpness)
{
    return BilateralDepth(target, uv, fixed2(1, 0), texelSize, sample, sharpness);
}

fixed4 BilateralDepth_Y(sampler2D target, half2 uv, float2 texelSize, int sample, float sharpness)
{
    return BilateralDepth(target, uv, fixed2(0, 1), texelSize, sample, sharpness);
}