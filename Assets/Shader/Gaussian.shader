﻿Shader "Hidden/Gaussian"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #include "Impl.cginc"

            #pragma vertex vert
            #pragma fragment frag_Gaussian_X

            ENDCG
        }

        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "Filter.hlsl"
            #include "Impl.cginc"

            #pragma vertex vert
            #pragma fragment frag_Gaussian_Y

            ENDCG
        }
    }
}
