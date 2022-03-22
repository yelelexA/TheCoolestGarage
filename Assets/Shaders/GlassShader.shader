Shader "TZ/GlassShader"
{
    Properties
    {
        [HideInInspector] _MainTex ("Albedo (RGB)", 2D) = "white"{}
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        _Opacity ("Opacity", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard alpha
        #pragma target 3.0

        sampler2D _MainTex;
        half _Smoothness;
        float _Opacity;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Alpha = IN.uv_MainTex * _Opacity;
            o.Smoothness = _Smoothness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
