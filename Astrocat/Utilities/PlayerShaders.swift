//
//  PlayerShaders.swift
//  Astrocat
//
//  Created by Arya on 20/05/26.
//

import SpriteKit

enum CatColorVariant: Int, CaseIterable {
    case white  = 0
    case orange = 1
    case blue   = 2
    case alien  = 3
    
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
                SKUniform(name: "u_tint_r", float: 1.0),
                SKUniform(name: "u_tint_g", float: 1.0),
                SKUniform(name: "u_tint_b", float: 1.0),
            ]
        case .gray:
            shader.uniforms = [
                SKUniform(name: "u_tint_r", float: 1.0),
                SKUniform(name: "u_tint_g", float: 0.5),
                SKUniform(name: "u_tint_b", float: 0.1),
            ]
        case .orange:
            shader.uniforms = [
                SKUniform(name: "u_tint_r", float: 0.2),
                SKUniform(name: "u_tint_g", float: 0.6),
                SKUniform(name: "u_tint_b", float: 1.0),
            ]
        case .alien:
            shader.uniforms = [
                SKUniform(name: "u_tint_r", float: 0.3),
                SKUniform(name: "u_tint_g", float: 1.0),
                SKUniform(name: "u_tint_b", float: 0.3),
            ]
        }
        
        return shader
    }
}
