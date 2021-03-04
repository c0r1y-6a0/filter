fixed4 Radial(sampler2D target, half2 uv, float samples, float radius, half2 center, float power)
{
    fixed4 col = 0;
    float2 dist = uv - center;
    float v1 = saturate(length(dist)/ radius);
    UNITY_LOOP
    for(float j = 0; j < samples; j++) {
        float scale = 1 - pow((j / samples) * v1, power);
        col += tex2D(target, dist * scale + center);
        //col += tex2D(target, length(dist) < 0.1 ? uv: (dist * scale + center));
    }
    col /= samples;
    return col;
}

fixed4 DirectionalBlur(sampler2D target, float2 uv, int range, half2 dir)
{
    fixed4 color = 0;
    float v1 = 1.0 / float(range);
    UNITY_LOOP
    for(float i = 0 ; i < 1.0; i += v1)
    {
        color += tex2D(target, uv + dir * i);
    }
    color *= v1;
    return color;
}

static const float Gaussian_Weight[5] = {0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216};
fixed4 Gaussian(sampler2D target, half2 uv, fixed2 dir, float step, int sample)
{
    fixed4 color = tex2D(target, uv) * Gaussian_Weight[0];
    UNITY_LOOP
    for(int i = 1 ; i < sample; i++)
    {
        color += tex2D(target, uv + dir * step * i) * Gaussian_Weight[i];
        color += tex2D(target, uv + -dir * step * i) * Gaussian_Weight[i];
    }

    return color;
}

fixed4 Gaussian_X(sampler2D target, half2 uv, float step, int sample)
{
    return Gaussian(target,uv, fixed2(1, 0), step, sample);
}

fixed4 Gaussian_Y(sampler2D target, half2 uv, float step, int sample)
{
    return Gaussian(target,uv, fixed2(0, 1), step, sample);
}

