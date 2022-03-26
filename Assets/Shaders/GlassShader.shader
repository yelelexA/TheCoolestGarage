Shader "TZ/GlassShader"
{
	Properties
	{
		_Color("Color", Color) = (0, 0, 0, 0)
        _Opacity("Opacuty", Range(0, 1)) = 0.5
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" }

		Pass
		{
			Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

            uniform float4	_Color;
            float _Opacity;

            struct vertexInput{
                float4 vertex : POSITION;
            };

            struct vertexOutput{
                float4 pos : SV_POSITION;
            };

            vertexOutput vert(vertexInput input){
                vertexOutput output;
                output.pos = UnityObjectToClipPos(input.vertex);
                return output;
            }

            float4 frag(vertexOutput input) : COLOR{
                float3 rgb = min(min(_Color.x, _Color.y), _Color.z);
                 rgb = rgb > 0.3 ? 0.3 : rgb;

                float4 output = float4(rgb, _Opacity);
                return output;
            }
            ENDCG
		}			
	}	
}