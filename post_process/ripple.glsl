#ifdef CIRCLE

vec4 resultCol;
float dist;
uniform float time;
uniform float swidth = 50;
uniform float sfunction = 2;
uniform float fall = 1;
float power;

vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
{
	dist = distance(texturePos , vec2 (0.5,0.5))*1000;
	if ((dist < time+swidth) && (dist > time-swidth))
	{
		power = 1.0-pow(abs(dist-time)/swidth,sfunction); //0.16
		{
			resultCol = vec4(normalize(texturePos-vec2 (0.5,0.5))*0.5+vec2 (0.5,0.5), power, fall);
		}
	}
	else
	{
		resultCol = vec4 (0,0,0,0);
	}
	return resultCol;
}

#else

vec4 resultCol;
uniform sampler2D canvas;

vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
{
	resultCol = texture2D(texture, texturePos+vec2 (texture2D(canvas, texturePos).r*2-1, texture2D(canvas, texturePos).g*2-1)*0.05*texture2D(canvas, texturePos).b*texture2D(canvas, texturePos).a);
	return resultCol;
}

#endif
