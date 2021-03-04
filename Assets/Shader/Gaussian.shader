Shader "Unlit/Gaussian"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Step("Step", Range(0, 0.01)) = 0.01
        _Sample("Sample", Int) = 3
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "Filter.hlsl"
            #include "Gaussian_impl.cginc"

            #pragma vertex vert
            #pragma fragment frag_X

            ENDCG
        }

        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "Filter.hlsl"
            #include "Gaussian_impl.cginc"

            #pragma vertex vert
            #pragma fragment frag_Y

            ENDCG
        }
    }
}
