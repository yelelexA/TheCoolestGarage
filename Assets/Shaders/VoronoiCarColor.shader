Shader "TZ/CarColorVoronoi" 
{
	Properties 
    {        
        _Color ("Main Color", Color) = (0.02264148,0.4396222,1,1)		
        _BorderColor ("Border Color", Color) = (1,1,1,1)
        _CellSize ("Cell Size", Range(0.1, 2)) = 1.4
        _Metallic ("Metalic", Range(0,1)) = 0.6
        _Smoothness ("Smoothness", Range(0,1)) = 0.745
	}
	SubShader 
    {
		Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows vertex:vert
		#pragma target 3.0

		// #include "Random.cginc"

		float4 _Color;
        float3 _BorderColor;
        float _CellSize;
        half _Metallic;
        half _Smoothness;

		struct Input {
			float3 worldPos;
            float3 localPos;
		};



        ///                                ///
        ///     #include "Random.cginc"    ///
        ///                                ///
        float rand4dTo1d(float4 value, float4 dotDir = float4(12.9898, 78.233, 37.719, 17.4265)){
            float4 smallValue = sin(value);
            float random = dot(smallValue, dotDir);
            random = frac(sin(random) * 143758.5453);
            return random;
        }

        float rand3dTo1d(float3 value, float3 dotDir = float3(12.9898, 78.233, 37.719)){
            float3 smallValue = sin(value);
            float random = dot(smallValue, dotDir);
            random = frac(sin(random) * 143758.5453);
            return random;
        }

        float rand2dTo1d(float2 value, float2 dotDir = float2(12.9898, 78.233)){
            float2 smallValue = sin(value);
            float random = dot(smallValue, dotDir);
            random = frac(sin(random) * 143758.5453);
            return random;
        }

        float rand1dTo1d(float3 value, float mutator = 0.546){
            float random = frac(sin(value + mutator) * 143758.5453);
            return random;
        }

        float2 rand3dTo2d(float3 value){
            return float2(
                rand3dTo1d(value, float3(12.989, 78.233, 37.719)),
                rand3dTo1d(value, float3(39.346, 11.135, 83.155)));
        }

        float2 rand2dTo2d(float2 value){
            return float2(
                rand2dTo1d(value, float2(12.989, 78.233)),
                rand2dTo1d(value, float2(39.346, 11.135)));
        }

        float2 rand1dTo2d(float value){
            return float2(
                rand2dTo1d(value, 3.9812),
                rand2dTo1d(value, 7.1536));
        }

        float3 rand3dTo3d(float3 value){
            return float3(
                rand3dTo1d(value, float3(12.989, 78.233, 37.719)),
                rand3dTo1d(value, float3(39.346, 11.135, 83.155)),
                rand3dTo1d(value, float3(73.156, 52.235, 09.151)));
        }

        float3 rand2dTo3d(float2 value){
            return float3(
                rand2dTo1d(value, float2(12.989, 78.233)),
                rand2dTo1d(value, float2(39.346, 11.135)),
                rand2dTo1d(value, float2(73.156, 52.235)));
        }

        float3 rand1dTo3d(float value){
            return float3(
                rand1dTo1d(value, 3.9812),
                rand1dTo1d(value, 7.1536),
                rand1dTo1d(value, 5.7241));
        }

        float4 rand4dTo4d(float4 value){
            return float4(
                rand4dTo1d(value, float4(12.989, 78.233, 37.719, -12.15)),
                rand4dTo1d(value, float4(39.346, 11.135, 83.155, -11.44)),
                rand4dTo1d(value, float4(73.156, 52.235, 09.151, 62.463)),
                rand4dTo1d(value, float4(-12.15, 12.235, 41.151, -1.135)));
        }
        ///                                ///
        ///     #include "Random.cginc"    ///
        ///                                ///



		float3 voronoiNoise(float3 value){
			float3 baseCell = floor(value);
			float minDistToCell = 10;
			float3 toClosestCell;
			float3 closestCell;

			[unroll]
			for(int x1=-1; x1<=1; x1++){

				[unroll]
				for(int y1=-1; y1<=1; y1++){

					[unroll]
					for(int z1=-1; z1<=1; z1++){
						float3 cell = baseCell + float3(x1, y1, z1);
						float3 cellPosition = cell + rand3dTo3d(cell);
						float3 toCell = cellPosition - value;
						float distToCell = length(toCell);

						if(distToCell < minDistToCell){
							minDistToCell = distToCell;
							closestCell = cell;
							toClosestCell = toCell;
						}
					}
				}
			}



			float minEdgeDistance = 10;
            
			[unroll]
			for(int x2=-1; x2<=1; x2++){

				[unroll]
				for(int y2=-1; y2<=1; y2++){

					[unroll]
					for(int z2=-1; z2<=1; z2++){
						float3 cell = baseCell + float3(x2, y2, z2);
						float3 cellPosition = cell + rand3dTo3d(cell);
						float3 toCell = cellPosition - value;
                        float3 diffToClosestCell = abs(closestCell - cell);
						bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y + diffToClosestCell.z < 0.1;

						if(!isClosestCell){
							float3 toCenter = (toClosestCell + toCell) * 0.5;
							float3 cellDifference = normalize(toCell - toClosestCell);
							float edgeDistance = dot(toCenter, cellDifference);
							minEdgeDistance = min(minEdgeDistance, edgeDistance);
						}
					}
				}
			}

			float random = rand3dTo1d(closestCell);
    		return float3(minDistToCell, random, minEdgeDistance);
		}

        void vert(inout appdata_full v, out Input o){
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.localPos = v.vertex.xyz;
        }

		void surf (Input IN, inout SurfaceOutputStandard o) {
			float3 value = IN.localPos.xyz / _CellSize;
			float3 noise = voronoiNoise(value);
			float3 cellColor = rand1dTo3d(noise.y) * _Color; 
			float valueChange = fwidth(value.z) * 0.5;
			float isBorder = 1 - smoothstep(0.05 - valueChange, 0.05 + valueChange, noise.z);
			float3 color = lerp(cellColor, _BorderColor, isBorder);

			o.Albedo = color;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
		}
		ENDCG
	}
	FallBack "Standard"
}