Shader "Hidden/Bilateral"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Sample("Sample", Int) = 3
        _BilateralSharpness("Bilateral Sharpness", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Filter.hlsl"
            #include "Impl.cginc"

            #pragma vertex vert
            #pragma fragment frag_BilateralDepth_X
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Filter.hlsl"
            #include "Impl.cginc"

            #pragma vertex vert
            #pragma fragment frag_BilateralDepth_Y
            ENDCG
        }
    }
}
