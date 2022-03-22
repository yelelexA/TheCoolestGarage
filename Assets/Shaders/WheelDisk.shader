Shader "TZ/WheelDisk"
{
    Properties
    {
        [HideInInspector] _MainTex ("Albedo (RGB)", 2D) = "white"{}
        _Color ("Main Color (RGB)", Color) = (1,1,1,1)
        _Metalic ("Metalic", Range(0,1)) = 0.6
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        // _Opacity ("Opacity", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows 
        #pragma target 3.0

        sampler2D _MainTex;
        float4 _Color;
        half _Metallic;
        half _Smoothness;
        
        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Albedo = _Color;
            // Это был очень сложный код)))
        }
        ENDCG
    }
    FallBack "Diffuse"
}
