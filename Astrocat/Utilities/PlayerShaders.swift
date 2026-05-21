//
//  PlayerShaders.swift
//  Astrocat
//
//  Created by Arya on 20/05/26.
//

import SpriteKit

enum CatColorVariant: Int, CaseIterable {
    case white  = 0   // pure white cat
    case cream  = 1   // warm pale yellow-beige
    case blue   = 2   // muted blue-gray (diluted black)
    case fawn   = 3   // warm light tan (diluted cinnamon)
    
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
        
        switch self {
        case .white:
                // Pure white — no shift
            shader.uniforms = [
                SKUniform(name: "u_tint_r", float: 1.00),
                SKUniform(name: "u_tint_g", float: 1.00),
                SKUniform(name: "u_tint_b", float: 1.00),
            ]
        case .cream:
                // Barely warm ivory — almost white with a faint yellow warmth
            shader.uniforms = [
                SKUniform(name: "u_tint_r", float: 1.00),
                SKUniform(name: "u_tint_g", float: 0.97),
                SKUniform(name: "u_tint_b", float: 0.88),
            ]
        case .blue:
                // Very pale cool gray — like a British Blue in soft light
            shader.uniforms = [
                SKUniform(name: "u_tint_r", float: 0.88),
                SKUniform(name: "u_tint_g", float: 0.92),
                SKUniform(name: "u_tint_b", float: 0.96),
            ]
        case .fawn:
                // Warm pinkish tan — diluted cinnamon, not orange
            shader.uniforms = [
                SKUniform(name: "u_tint_r", float: 1.00),
                SKUniform(name: "u_tint_g", float: 0.92),
                SKUniform(name: "u_tint_b", float: 0.78),
            ]
        }
        
        return shader
    }
}
