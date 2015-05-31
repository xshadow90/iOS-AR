/**
 * OcvARBasicNativeCam - Basic ocv_ar example for iOS with native camera usage
 *
 * gl view - implementation file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, June 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * BSD licensed (see LICENSE file).
 */

#import "CC3GLMatrix.h"
#import "GLView.h"
#import "cube.h"

#define QUAD_VERTICES 				4
#define QUAD_COORDS_PER_VERTEX      3
#define QUAD_TEXCOORDS_PER_VERTEX 	2
#define QUAD_VERTEX_BUFSIZE 		(QUAD_VERTICES * QUAD_COORDS_PER_VERTEX)
#define QUAD_TEX_BUFSIZE 			(QUAD_VERTICES * QUAD_TEXCOORDS_PER_VERTEX)

// vertex data for a quad
const GLfloat quadVertices[] = {
    -1, -1, 0,
    1, -1, 0,
    -1,  1, 0,
    1,  1, 0 };


//@interface GLView(Private)
///**
// * set up OpenGL
// */
//- (void)setupGL;
//
///**
// * initialize shaders
// */
//- (void)initShaders;
//
///**
// * build a shader <shader> from source <src>
// */
//- (BOOL)buildShader:(Shader *)shader src:(NSString *)src;
//
///**
// * draw a <marker>
// */
//- (void)drawMarker:(const ocv_ar::Marker *)marker;
//@end


@implementation GLView

@synthesize tracker;
@synthesize markerProjMat;
@synthesize markerScale;
@synthesize showMarkers;

#pragma mark init/dealloc

- (id)initWithFrame:(CGRect)frame {
//    // create context
//    EAGLContext *ctx = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];
//    [EAGLContext setCurrentContext:ctx];
//    
//    // init
//    self = [super initWithFrame:frame context:ctx];
    NSLog(@"GLView: init with frame");
    
    self = [super initWithFrame:frame];
    
    if (self) {
        // defaults
        glInitialized = NO;
        showMarkers = YES;
        
        markerProjMat = NULL;
        
        memset(markerScaleMat, 0, sizeof(GLfloat) * 16);
        [self setMarkerScale:1.0f];
        
        [self setupLayer];
        [self setupContext];
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        
        // add the render method of our GLView to the main run loop in order to
        // render every frame periodically
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        // configure
//        [self setEnableSetNeedsDisplay:NO]; // important to render every frame periodically and not on demand!
//        [self setOpaque:NO];                // we have a transparent overlay
//        
//        [self setDrawableColorFormat:GLKViewDrawableColorFormatRGBA8888];
//        [self setDrawableDepthFormat:GLKViewDrawableDepthFormat24];
//        [self setDrawableStencilFormat:GLKViewDrawableStencilFormat8];
        
        _cubeTexture = [self setupTexture:@"cube.png"];
    }
    
    return self;
}

#pragma mark parent methods

//- (void)drawRect:(CGRect)rect {
//- (void)render:(CADisplayLink*)displayLink {
//    if (!glInitialized) return;
//    
//    // Clear the framebuffer
//    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);   // 0.0f for alpha is important for non-opaque gl view!
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
////    glEnable(GL_DEPTH_TEST);
//    
//    
//    
//    if (!showMarkers) return;   // break here in order not to display markers
//    
//    // update the tracker to smoothly move to new marker positions
//    tracker->update();
//    
//    // use the marker shader
//    markerDispShader.use();
//    
//    if (markerProjMat) {
//        tracker->lockMarkers();     // lock the tracked markers, because they might get updated in a different thread
//        
//        // draw each marker
//        const ocv_ar::MarkerMap *markers = tracker->getMarkers();
//        for (ocv_ar::MarkerMap::const_iterator it = markers->begin();
//             it != markers->end();
//             ++it)
//        {
//            [self drawMarker:&(it->second)];
//        }
//        
//        tracker->unlockMarkers();   // unlock the tracked markers again
//    }
//}

- (void)render:(CADisplayLink*)displayLink {
    //    glClearColor(0, 0.5, 0.5, 0.0);
    glClearColor(0.0f, 0.5f, 0.5f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:4 andFar:10];
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(0, 0, -7)];
    _currentRotation += displayLink.duration * 180;
    [modelView rotateBy:CC3VectorMake(_currentRotation, 2 * _currentRotation, 0)];
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    
    // 1
    
    
    // 2
    
    float markerColor[] = { 1, 1, 1, 1 };
    glUniform4fv(_colorSlot, 1, markerColor);
    
    //    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
    //                          sizeof(Vertex), 0);
    //    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE,
    //                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    
    // Positions
    glEnableVertexAttribArray(_positionSlot);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, cubePositions);
    
    // Texture
    glEnableVertexAttribArray(_texCoordSlot);
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, 0, cubeTexels);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _cubeTexture);
    glUniform1i(_textureUniform, 0);
    
    
    // 3
    //    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
    //                   GL_UNSIGNED_BYTE, 0);
    glDrawArrays(GL_TRIANGLES, 0, cubeVertices);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    //    glDisableVertexAttribArray(_positionSlot);
}

- (void)resizeView:(CGSize)size {
    NSLog(@"GLView: resizing to frame size %dx%d",
          (int)size.width, (int)size.height);
    
    if (!glInitialized) {
        NSLog(@"GLView: initializing GL");
        
        [self setupGL];
    }
    
    // handle retina displays, too:
    float scale = [[UIScreen mainScreen] scale];
    viewportSize = CGSizeMake(size.width * scale, size.height * scale);
    
    [self setNeedsDisplay];
}

#pragma mark public methods

//- (void)render:(CADisplayLink *)displayLink {
//    [self display];
//}

- (void)setMarkerScale:(float)s {
    markerScale = s;
    
    // set 4x4 matrix diagonal to s
    // markerScaleMat must be zero initialized!
    for (int i = 0; i < 3; ++i) {
        markerScaleMat[i * 5] = s * 0.5f;
    }
    markerScaleMat[15] = 1.0f;
}

#pragma mark private methods

- (void)setMatrixes {
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:4 andFar:10];
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(0, 0, -7)];
    _currentRotation += displayLink.duration * 180;
    [modelView rotateBy:CC3VectorMake(_currentRotation, 2 * _currentRotation, 0)];
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
}

- (void)drawMarker:(const ocv_ar::Marker *)marker {
    // set matrixes
//    glUniformMatrix4fv(shMarkerProjMat, 1, false, markerProjMat);
//    glUniformMatrix4fv(shMarkerModelViewMat, 1, false, marker->getPoseMatPtr());
//    glUniformMatrix4fv(shMarkerTransformMat, 1, false, markerScaleMat);
    
//    [self setMatrixes];
    glViewport(0, 0, viewportSize.width, viewportSize.height);
    
//    int id = marker->getId();
//    float idR = (float) ((id * id) % 1024);
//    float idG = (float) ((id * id * id) % 1024);
//    float idB = (float) ((id * id * id * id) % 1024);
    
    float markerColor[] = { 1, 1, 1, 1 };
    glUniform4fv(shMarkerColor, 1, markerColor);
    
//    // set geometry
//    glEnableVertexAttribArray(shAttrPos);
//    glVertexAttribPointer(shAttrPos,
//                          QUAD_COORDS_PER_VERTEX,
//                          GL_FLOAT,
//                          GL_FALSE,
//                          0,
//                          cubePositions);
//    
//    glEnableVertexAttribArray(_texCoordSlot);
//    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE,
//                          0, cubeTexels);
//    
//    glActiveTexture(GL_TEXTURE0);
//    glBindTexture(GL_TEXTURE_2D, _cubeTexture);
//    glUniform1i(_textureUniform, 0);

    
//    // draw
//    glDrawArrays(GL_TRIANGLES, 0, cubeVertices);
//    [_context presentRenderbuffer:GL_RENDERBUFFER];
//    
//    // cleanup
//    glDisableVertexAttribArray(shAttrPos);
//    glDisableVertexAttribArray(_texCoordSlot);
}

- (void)setupGL {
    [self initShaders];
    
    glDisable(GL_CULL_FACE);
    
    glInitialized = YES;
}

- (void)initShaders {
    [self buildShader:&markerDispShader src:@"marker"];
    shMarkerProjMat = markerDispShader.getParam(UNIF, "uProjMat");
    shMarkerModelViewMat = markerDispShader.getParam(UNIF, "uModelViewMat");
    shMarkerTransformMat = markerDispShader.getParam(UNIF, "uTransformMat");
    shMarkerColor = markerDispShader.getParam(UNIF, "SourceColor");
    
    // new
    _texCoordSlot = markerDispShader.getParam(ATTR, "TexCoordIn");
    _textureUniform = markerDispShader.getParam(UNIF, "Texture");
    
    printf("%d  %d  %d  %d\n", shMarkerProjMat, shMarkerModelViewMat, shMarkerTransformMat, shMarkerColor);
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}

- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (GLuint)setupTexture:(NSString *)fileName {
    // 1
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);        
    return texName;    
}

- (BOOL)buildShader:(Shader *)shader src:(NSString *)src {
    NSString *vshFile = [[NSBundle mainBundle] pathForResource:[src stringByAppendingString:@"_v"]
                                                        ofType:@"glsl"];
    NSString *fshFile = [[NSBundle mainBundle] pathForResource:[src stringByAppendingString:@"_f"]
                                                        ofType:@"glsl"];
    
    const NSString *vshSrc = [NSString stringWithContentsOfFile:vshFile encoding:NSASCIIStringEncoding error:NULL];
    if (!vshSrc) {
        NSLog(@"GLView: could not load shader contents from file %@", vshFile);
        return NO;
    }
    
    const NSString *fshSrc = [NSString stringWithContentsOfFile:fshFile encoding:NSASCIIStringEncoding error:NULL];
    if (!fshSrc) {
        NSLog(@"GLView: could not load shader contents from file %@", fshFile);
        return NO;
    }
    
    return shader->buildFromSrc([vshSrc cStringUsingEncoding:NSASCIIStringEncoding],
                                [fshSrc cStringUsingEncoding:NSASCIIStringEncoding]);
}

@end