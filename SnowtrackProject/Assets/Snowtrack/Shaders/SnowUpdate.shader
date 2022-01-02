Shader "Snowtrack/SnowUpdate"
{
    //this shader is used for editing the camera depth map, it does nothing but just return the colors
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color", color) = (0.1, 0.1, 0.1,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
            float4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f 
            {
                float2 uv : TEXCOORD0;
                float4 scrPos:TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeScreenPos(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //get color based on current uv coord (depth map), so we can update the snow plane
                fixed4 mainColor = tex2D(_MainTex, i.uv);              
                return mainColor;
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
