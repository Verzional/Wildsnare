//
//  PlayerShaders.swift
//  Astrocat
//
//  Created by Arya on 20/05/26.
//

import SpriteKit

enum CatColorVariant: Int, CaseIterable {
    case white    = 0   // pure white cat
    case cream    = 1   // warm pale yellow-beige
    case blue     = 2   // muted blue-gray (diluted black)
    case fawn     = 3   // warm light tan (diluted cinnamon)
    case lavender = 4   // soft purple-gray
    case mint     = 5   // cool mint green
    case peach    = 6   // warm peach-pink
    case slate    = 7   // cool dark gray
    case coral    = 8   // warm coral-orange
    case sky      = 9   // light sky blue
    case lilac    = 10  // soft pink-purple
    case sage     = 11  // muted green-gray
    case apricot  = 12  // warm golden-orange
    case ice      = 13  // very pale icy blue
    case rose     = 14  // dusty rose pink
    case charcoal = 15  // dark warm gray
    
    /// All variants suitable for remote players (excludes white which is the local player)
    static let remoteVariants: [CatColorVariant] = CatColorVariant.allCases.filter { $0 != .white }
    
    func makeShader() -> SKShader {
        let src = """
    void main() {
        vec4 tex = texture2D(u_texture, v_tex_coord);
    
        // Preserve original luminance so shading/outlines stay intact.
        // Only the hue shifts — bright pixels stay bright, dark pixels stay dark.
        float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
        vec3 tinted = vec3(u_tint_r, u_tint_g, u_tint_b) * lum;
    
        gl_FragColor = vec4(tinted, tex.a);
    }
    """
        
        let shader = SKShader(source: src)
        let (r, g, b) = tintValues
        shader.uniforms = [
            SKUniform(name: "u_tint_r", float: r),
            SKUniform(name: "u_tint_g", float: g),
            SKUniform(name: "u_tint_b", float: b),
        ]
        return shader
    }
    
    private var tintValues: (Float, Float, Float) {
        switch self {
        case .white:    return (1.00, 1.00, 1.00)
        case .cream:    return (1.00, 0.97, 0.88)
        case .blue:     return (0.88, 0.92, 0.96)
        case .fawn:     return (1.00, 0.92, 0.78)
        case .lavender: return (0.90, 0.85, 0.98)
        case .mint:     return (0.82, 0.98, 0.90)
        case .peach:    return (1.00, 0.87, 0.82)
        case .slate:    return (0.78, 0.80, 0.84)
        case .coral:    return (1.00, 0.80, 0.70)
        case .sky:      return (0.80, 0.92, 1.00)
        case .lilac:    return (0.95, 0.82, 0.95)
        case .sage:     return (0.82, 0.90, 0.80)
        case .apricot:  return (1.00, 0.88, 0.68)
        case .ice:      return (0.90, 0.96, 1.00)
        case .rose:     return (0.96, 0.82, 0.86)
        case .charcoal: return (0.75, 0.73, 0.72)
        }
    }
}
