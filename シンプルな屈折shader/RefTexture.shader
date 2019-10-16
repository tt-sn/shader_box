Shader "Unlit/Shader2"
{
	Properties
	{
		_MainTex("Texture"	  , 2D) = "white" {}
		_Color("Color(RGB)" ,color) = (1,1,1,1)
		_Distance("距離"		, float) = 1.0
	}
		SubShader
		{
			Tags {
					"RenderType" = "Transparent"
					"Queue" = "Transparent"
					"LightMode" = "ForwardBase"
				 }

			LOD 100

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					half3  normal : NORMAL;
					float2 uv	  : TEXCOORD0;
				};

				struct v2f
				{
					float4 pos		: SV_POSITION;
					half2 uv		: TEXCOORD0;
					half3 normal	: TEXCOORD1;
					half3 viewDir	: TEXCOORD4;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				half4 _Color;
				float _Distance;

				v2f vert(appdata v)
				{
					v2f o = (v2f)0;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv , _MainTex);

					//正規化した視線のベクトルを求める
					o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
					//正規化した頂点の法線ベクトル（ワールド空間）を求める
					o.normal = UnityObjectToWorldNormal(v.normal);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					/////////　　　ゆがみ関係のコード       ////////
					//視線ベクトルと法線ベクトルの内積を求める
					half3 dotViewNormal = dot(i.viewDir , i.normal);
					//UVを-1~1にする
					half2 UV = i.uv * 2 - 1;
					//法線ベクトルとの内積をUVにかけ合わせて球面のゆがみを表現
					UV *= dotViewNormal.xy * _Distance;
					//UV座標を0~1に戻す
					UV = (UV + 1) / 2;

					half4 base = tex2D(_MainTex, UV) * _Color;
					return base;
				}
				ENDCG
			}
		}
}
