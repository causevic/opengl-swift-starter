//
//  ViewController.swift
//  glCourse01
//
//  Created by Emir Causevic on 5/27/18.
//  Copyright © 2018 ecdev. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
    var program: GLuint = 0
    
    let triangle: [Float] = [
        0.80,  -0.30,
        -0.30,   0.70,
        -0.65,  -0.65,
        0.20,  0.30,
        -0.80,   0.20,
        -0.35,  -0.75
    ]
    
    let triangleTextureCoordinates: [Float] = [
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,
        1.0, 0.0,
        0.3, 0.9,
        0.4, 0.0,
    ]
    
    var animationX1: Float = 0
    var animationY1: Float = 0
    var animationX2: Float = 0
    var animationY2: Float = 0
    
    
    var scaleX1: Float = 1
    var scaleY1: Float = 1
    var scaleX2: Float = 1
    var scaleY2: Float = 1
    
    var forrestTextureInfo: GLKTextureInfo?
    var mountainTextureInfo: GLKTextureInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        let glkView : GLKView = view as! GLKView
        glkView.context = EAGLContext(api: .openGLES3)!
        EAGLContext.setCurrent(glkView.context)
        
        // vertex shader
        let vertexShaderSource: NSString = """
            attribute vec2 position;
            attribute vec2 textureCoordinate;
            uniform   vec2 translate;
            uniform   vec2 scale;
            varying   vec2 textureCoordinateInterpolated;
            void main() {
                gl_Position = vec4((position.x *scale.x + translate.x), (position.y *scale.y+ translate.y), 0.0, 1.0);
                textureCoordinateInterpolated = textureCoordinate;
            }
        """
        var vertexShaderSourceCString = vertexShaderSource.utf8String
        let vertexShader: GLuint = glCreateShader(GLenum(GL_VERTEX_SHADER))
        glShaderSource(vertexShader, 1, &vertexShaderSourceCString, nil)
        glCompileShader(vertexShader)
        var compileVertexSharedSuccess: GLint = 0
        glGetShaderiv(vertexShader, GLenum(GL_COMPILE_STATUS), &compileVertexSharedSuccess)
        
        // fragment shader
        let fragmentShaderSource: NSString = """
            varying highp vec2 textureCoordinateInterpolated;
            uniform sampler2D textureUnit;
            void main() {
                gl_FragColor = texture2D(textureUnit, textureCoordinateInterpolated);
            }
        """
        var fragmentShaderSourceCString = fragmentShaderSource.utf8String
        let fragmentShader: GLuint = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        glShaderSource(fragmentShader, 1, &fragmentShaderSourceCString, nil)
        glCompileShader(fragmentShader)
        var compileFragmentSharedSuccess: GLint = 0
        glGetShaderiv(fragmentShader, GLenum(GL_COMPILE_STATUS), &compileFragmentSharedSuccess)
        
        // create program and link shaders
        program = glCreateProgram()
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        glBindAttribLocation(program, 0, "position")
        glBindAttribLocation(program, 1, "textureCoordinate")
        glLinkProgram(program)
        var programLinkSuccess: GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &programLinkSuccess)
        
        glUseProgram(program)
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, triangle)
        glEnableVertexAttribArray(0)
        glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, triangleTextureCoordinates)
        glEnableVertexAttribArray(1)
        glUniform1i(glGetUniformLocation(program, "textureUnit"), 0)
        
        var textureImage: UIImage = UIImage(named: "forrest")!
        forrestTextureInfo  = try! GLKTextureLoader.texture(with: textureImage.cgImage!, options: [:])
        textureImage = UIImage(named: "mountain")!
        mountainTextureInfo = try! GLKTextureLoader.texture(with: textureImage.cgImage!, options: [:])
        glClearColor(1.0, 0, 0, 1.0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        animationX1 += 0.005
        animationY1 += 0.005
        scaleX1 -= 0.005
        scaleY1 -= 0.005

        
        animationX2 -= 0.015
        animationY2 -= 0.015
        scaleX2 += 0.005
        scaleY2 += 0.005

        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glUniform2f(glGetUniformLocation(program, "translate"), animationX1, animationY1)
        glUniform2f(glGetUniformLocation(program, "scale"), scaleX1, scaleY1)
        glBindTexture(GLenum(GL_TEXTURE_2D), forrestTextureInfo!.name)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3 /* vertices count!!!*/)
        
        glBindTexture(GLenum(GL_TEXTURE_2D), mountainTextureInfo!.name)
        glUniform2f(glGetUniformLocation(program, "translate"), animationX2, animationY2)
        glUniform2f(glGetUniformLocation(program, "scale"), scaleX2, scaleY2)
        glDrawArrays(GLenum(GL_TRIANGLES), 3, 3 /* vertices count!!!*/)

    }


}

