//
//  PlayerShaders.swift
//  Astrocat
//
//  Created by Arya on 20/05/26.
//

import SpriteKit

enum CatColorVariant: Int, CaseIterable {
    case white  = 0   // no hue shift, desaturated
    case gray   = 1   // no hue shift, desaturated darker
    case orange = 2   // warm hue shift
    case alien  = 3   // green hue shift
    
        /// Returns a configured SKShader for this color variant
    func makeShader() -> SKShader {
        let src = """
        void main() {
            vec4 texColor = texture2D(u_texture, v_tex_coord);
            if (texColor.a < 0.01) {
                gl_FragColor = texColor;
                return;
            }
        
            // Convert RGB to HSL
            vec3 rgb = texColor.rgb / texColor.a; // un-premultiply
            float maxC = max(rgb.r, max(rgb.g, rgb.b));
            float minC = min(rgb.r, min(rgb.g, rgb.b));
            float delta = maxC - minC;
        
            float h = 0.0;
            float s = 0.0;
            float l = (maxC + minC) / 2.0;
        
            if (delta > 0.001) {
                s = delta / (1.0 - abs(2.0 * l - 1.0));
                if (maxC == rgb.r)      h = mod((rgb.g - rgb.b) / delta, 6.0);
                else if (maxC == rgb.g) h = (rgb.b - rgb.r) / delta + 2.0;
                else                    h = (rgb.r - rgb.g) / delta + 4.0;
                h /= 6.0;
                if (h < 0.0) h += 1.0;
            }
        
            // Apply variant transform
            h = mod(h + u_hue_shift, 1.0);
            s *= u_saturation_scale;
            l = clamp(l * u_lightness_scale, 0.0, 1.0);
        
            // Convert HSL back to RGB
            float c2 = (1.0 - abs(2.0 * l - 1.0)) * s;
            float x2 = c2 * (1.0 - abs(mod(h * 6.0, 2.0) - 1.0));
            float m2 = l - c2 / 2.0;
            vec3 result;
            float h6 = h * 6.0;
            if      (h6 < 1.0) result = vec3(c2, x2, 0.0);
            else if (h6 < 2.0) result = vec3(x2, c2, 0.0);
            else if (h6 < 3.0) result = vec3(0.0, c2, x2);
            else if (h6 < 4.0) result = vec3(0.0, x2, c2);
            else if (h6 < 5.0) result = vec3(x2, 0.0, c2);
            else                result = vec3(c2, 0.0, x2);
        
            result = (result + m2) * texColor.a; // re-premultiply
            gl_FragColor = vec4(result, texColor.a);
        }
        """
        
        let shader = SKShader(source: src)
        
        switch self {
        case .white:
                // Desaturated, slightly brightened — white/cream cat
            shader.uniforms = [
                SKUniform(name: "u_hue_shift",        float: 0.0),
                SKUniform(name: "u_saturation_scale", float: 0.1),
                SKUniform(name: "u_lightness_scale",  float: 1.3),
            ]
        case .gray:
                // Desaturated, normal brightness — gray cat
            shader.uniforms = [
                SKUniform(name: "u_hue_shift",        float: 0.0),
                SKUniform(name: "u_saturation_scale", float: 0.15),
                SKUniform(name: "u_lightness_scale",  float: 0.85),
            ]
        case .orange:
                // Shift hue toward orange (0.07 = ~25° on the color wheel)
            shader.uniforms = [
                SKUniform(name: "u_hue_shift",        float: 0.07),
                SKUniform(name: "u_saturation_scale", float: 1.4),
                SKUniform(name: "u_lightness_scale",  float: 1.0),
            ]
        case .alien:
                // Shift hue toward green (0.25 = ~90° on the color wheel)
            shader.uniforms = [
                SKUniform(name: "u_hue_shift",        float: 0.25),
                SKUniform(name: "u_saturation_scale", float: 1.5),
                SKUniform(name: "u_lightness_scale",  float: 0.95),
            ]
        }
        
        return shader
    }
}
