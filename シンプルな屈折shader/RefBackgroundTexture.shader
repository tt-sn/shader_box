Shader "Unlit/RefBackgroundTexture"
{
	Properties
	{
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

			GrabPass{}

			Pass
			{
				CGPROGRAM
				#pragma target 3.0
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
					float4 grabPos  : TEXCOORD6;
				};

				sampler2D _GrabTexture;
				half4 _Color;
				float _Distance;


				v2f vert(appdata v)
				{
					v2f o = (v2f)0;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.grabPos = ComputeGrabScreenPos(o.pos);
					
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
					//取得した背景テクスチャのUVを取得する
					half2 grabUV = (i.grabPos.xy / i.grabPos.w);
					//UVを-1~1にする
					half2 UV = grabUV * 2 - 1;
					//法線ベクトルとの内積をUVにかけ合わせて球面のゆがみを表現
					UV *= dotViewNormal.xy * _Distance;
					//UV座標を0~1に戻す
					grabUV = (UV + 1) / 2;
					
					half4 base = tex2D(_GrabTexture, grabUV) * _Color;

					return base;
				}
				ENDCG
			}
		}
}
