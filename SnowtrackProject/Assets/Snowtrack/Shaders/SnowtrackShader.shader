Shader "Snowtrack/SnowtrackShader"
{
    Properties
    {
        _SnowTex("Snow Surf Tex", 2D) = "white" {}
        _SnowColor("Snow Color", Color) = (1,1,1,1)
        _GroundTex("Ground Surf Tex", 2D) = "white" {}
        _GroundColor("Ground Color", Color) = (1,1,1,1)
        _CamDepthTex("Camera Depth Tex", 2D) = "white" {}
        _DispAmount("Disp Amount", Range(0, 1)) = 0.3
        _Tess("Tessellation", Range(1, 64)) = 4
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM
        #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessDistance nolightmap
        #pragma target 4.6
        #include "Tessellation.cginc"

        sampler2D _SnowTex;
        fixed4 _SnowColor;
        sampler2D _GroundTex;
        fixed4 _GroundColor;
        sampler2D _CamDepthTex;
        half _Glossiness;
        half _Metallic;
        half _DispAmount;
        float _Tess;

        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        struct Input
        {
            float2 uv_SnowTex;
            float2 uv_GroundTex;
            float2 uv_CamDepthTex;
            float2 uv_SurfDispTex;
        };

        //unity built-in distance based tessellation
        float4 tessDistance(appdata v0, appdata v1, appdata v2) {
            float minDist = 10.0;
            float maxDist = 25.0;
            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
        }

        void disp(inout appdata v)
        {
            //read the depth value from the camera depth map, apply the value to vertices based on their normal direction
            float d = tex2Dlod(_CamDepthTex, float4(1 - v.texcoord.x, v.texcoord.y, 0, 0)).r * _DispAmount;
            v.vertex.xyz += v.normal * d;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            //get the snow color on the current uv coord
            fixed4 snowColor = tex2D(_SnowTex, IN.uv_SnowTex) * _SnowColor;
            //get the ground color on the current uv coord
            fixed4 groundColor = tex2D(_GroundTex, IN.uv_GroundTex) * _GroundColor;
            //lerp between snow color and ground color
            float u = 1.0 - tex2D(_CamDepthTex, float2(1 - IN.uv_CamDepthTex.x, IN.uv_CamDepthTex.y)).r;
            fixed4 c = lerp(snowColor, groundColor, u);

            o.Albedo = c.rgb;
            o.Gloss = .5;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
