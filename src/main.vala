using GL;

public class GameState : Object {
    public int player1_points { get; set; default = 0; }
    public int player2_points { get; set; default = 0; }
    public unowned Ball ball;
    public unowned Paddle player1;
    public unowned Paddle player2;
    public Darkcore.EventCallback? on_score;
    
    public GameState () {
        base();
    }
    
    public void player1_add_point () {
        player1_points++;
    }
    
    public void player2_add_point () {
        player2_points++;
    }
    
    public void fire_score () {
        if (on_score != null) {
            on_score ();
        }
    }
    
}

public class Circle : Darkcore.Sprite {
    public double radius { get; set; default = 0.00; }
    public override void render () {
        const double DEG2RAD = 3.14159 / 180.00;

        glPushMatrix ();
        glTranslated (x, y, 0.00);
        
        if (scale_x != 1.00 || scale_y != 1.00) {
            glScaled (scale_x, scale_y, 1.00);
        }
        
        if (rotation != 0.00) {
            glRotated (rotation, 0.00, 0.00, 1.00);
        }
        
        glColor3ub ((GLubyte) color_r, (GLubyte) color_g, (GLubyte) color_b);
        
        glLineWidth ((GL.GLfloat) 3.00);
        
        glBegin(GL_LINE_LOOP);
        for (int i=0; i < 360; i++) {
            double degInRad = i * DEG2RAD;
            glVertex2d(
                Math.cos (degInRad) * radius, Math.sin (degInRad) * radius
            );
        }
        glEnd ();
        
        glPopMatrix ();
    } 
}

public class GameDemo : Object {
    public static int main (string[] args) {
        var engine = new Darkcore.Engine(640, 480);
        var state = new GameState();
        
        var sound = new Darkcore.Sound ("resources/87035__RunnerPack__menuSel.ogg");
        engine.sounds.add (sound);
        // Load textures
        engine.add_texture ("resources/font.png");
        engine.add_texture ("resources/fluffy-grass.png");
        
        // Add an event to the renderer
        engine.add_event(Darkcore.EventTypes.Render, () => {
            //print("HELL YEAH!");
        });
        
        var text = new Darkcore.SpriteNS.Text.from_texture(engine, 0);
        text.set_text ("Hello World!"); // Testing
        text.on_render = (engine, self) => {
            int fps = engine.frames_per_second;
            text.data = @"Frames per second: $fps";
        };
        engine.sprites.add (text);
        
        var player = new Paddle(ref engine);
        player.up = "w";
        player.down = "s";
        engine.sprites.add (player);
        
        var player2 = new Paddle(ref engine);
        player2.x = engine.width - 32;
        engine.sprites.add (player2);
        
        var ball = new Ball(ref engine);
        ball.left_paddle = player;
        ball.right_paddle = player2;
        engine.sprites.add (ball);
        
        state.player1 = player;
        state.player2 = player2;
        state.ball = ball;
    
        // This must be defined outside the score event
        // If defined inside the anon on score function
        // you'd get a segment fault :(
        Circle c = new Circle();
        c.x = engine.width / 2;
        c.y = engine.height / 2;
        c.radius = 34.00;
        
        state.on_score = () => {
            // Reset the ball
            ball.reset_location (engine);
            ball.pause ();
            
            engine.sprites.add (c);
            
            engine.add_timer(() => {
                ball.unpause ();
                engine.sprites.remove (c);
            }, 3000);
        };
        engine.gamestate = state;
                
        engine.run ();

        return 0;
    }
}
