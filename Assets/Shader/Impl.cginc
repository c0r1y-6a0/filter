struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    UNITY_FOG_COORDS(1)
    float4 vertex : SV_POSITION;
};

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_TexelSize;
int _Sample;
float _BilateralSharpness;

v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    UNITY_TRANSFER_FOG(o,o.vertex);
    return o;
}

fixed4 frag_Gaussian_X (v2f i) : SV_Target
{
    return Gaussian_X(_MainTex, i.uv, _MainTex_TexelSize.xy, _Sample);
}

fixed4 frag_Gaussian_Y (v2f i) : SV_Target
{
    return Gaussian_Y(_MainTex, i.uv, _MainTex_TexelSize.xy, _Sample);
}

fixed4 frag_BilateralDepth_X(v2f i):SV_TARGET
{
    return BilateralDepth_X(_MainTex, i.uv, _MainTex_TexelSize.xy, _Sample, _BilateralSharpness);
}

fixed4 frag_BilateralDepth_Y(v2f i):SV_TARGET
{
    return BilateralDepth_Y(_MainTex, i.uv, _MainTex_TexelSize.xy, _Sample, _BilateralSharpness);
}