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
        vec4 texColor = texture2D(u_texture, v_tex_coord);
        gl_FragColor = texColor * vec4(u_tint_r, u_tint_g, u_tint_b, 1.0);
    }
    """
        
        let shader = SKShader(source: src)
        
        switch self {
        case .white:
            shader.uniforms = [
                SKUniform(name: "u_tint_r", float: 1.00),
                SKUniform(name: "u_tint_g", float: 1.00),
                SKUniform(name: "u_tint_b", float: 1.00),
            ]
        case .cream:
            shader.uniforms = [
                SKUniform(name: "u_tint_r", float: 0.96),
                SKUniform(name: "u_tint_g", float: 0.89),
                SKUniform(name: "u_tint_b", float: 0.72),
            ]
        case .blue:
            shader.uniforms = [
                SKUniform(name: "u_tint_r", float: 0.61),
                SKUniform(name: "u_tint_g", float: 0.65),
                SKUniform(name: "u_tint_b", float: 0.69),
            ]
        case .fawn:
            shader.uniforms = [
                SKUniform(name: "u_tint_r", float: 0.90),
                SKUniform(name: "u_tint_g", float: 0.67),
                SKUniform(name: "u_tint_b", float: 0.44),
            ]
        }
}
