sampler2D _CameraDepthNormalsTexture;
float4 _CameraDepthNormalsTexture_TexelSize;
float4x4 invproj;

void GetDepthNormal(float2 uv, out float depth, out float3 normal)
{
    float4 depthnormal = tex2Dlod(_CameraDepthNormalsTexture, float4(uv, 0, 0));
    DecodeDepthNormal(depthnormal, depth, normal);
}

float3 ReconstructViewPos(float2 uv, float linear01Depth)
{
    float2 NDC = uv * 2 - 1;
    float3 clipVec = float3(NDC.x, NDC.y, 1.0) * _ProjectionParams.z;
    float3 viewVec = mul(invproj, clipVec.xyzz).xyz;
    return viewVec * linear01Depth;
}

float3 GetViewPosAndNormal(float2 uv, inout float3 normal)
{
    float depth;
    GetDepthNormal(uv, depth, normal);
    return ReconstructViewPos(uv, depth);
}