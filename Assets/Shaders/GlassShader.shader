Shader "TZ/GlassShader"
{
    Properties
    {
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        _Opacity ("Opacity", Range(0,1)) = 0.5
        _OpacityPower ("OpacityPower", Range(1,2)) = 1
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
        float _OpacityPower;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Alpha = _Opacity * _OpacityPower;
            o.Smoothness = _Smoothness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
