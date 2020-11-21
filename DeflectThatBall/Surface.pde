// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// An uneven surface boundary

class Surface {
  // We'll keep track of all of the surface points
  ArrayList<Vec2> surface;

  Body body;

  Surface(ArrayList<PVector> points) {
    construct(points);
  }

  void construct(ArrayList<PVector> points) {
    surface = new ArrayList<Vec2>();

    for (int i = 0; i < points.size() - 10; i+=10) {
      PVector point = points.get(i);

      // Here we keep track of the screen coordinates of the chain
      surface.add(new Vec2(point.x, point.y));
    }

    // This is what box2d uses to put the surface in its world
    ChainShape chain = new ChainShape();

    // We can add 3 vertices by making an array of 3 Vec2 objects
    Vec2[] vertices = new Vec2[surface.size()];
    for (int i = 0; i < vertices.length; i++) {
      vertices[i] = box2d.coordPixelsToWorld(surface.get(i));
    }

    try {
      chain.createChain(vertices, vertices.length);
      // The edge chain is now a body!
      BodyDef bd = new BodyDef();
      body = box2d.world.createBody(bd);
      // Shortcut, we could define a fixture if we
      // want to specify frictions, restitution, etc.
      body.createFixture(chain, 2);
    } 
    catch(AssertionError e) {
      println(e);
    }
    catch(RuntimeException e) {
      println(e);
    }
  }

  void killBody() {
    if (body != null) {
      box2d.destroyBody(body);
    }
  }

  // A simple function to just draw the edge chain as a series of vertex points
  void display() {
    // strokeWeight(10);
    // stroke(255, 255, 0);
    // fill(0);
    // beginShape();
    // for (Vec2 v : surface) {
    //   vertex(v.x, v.y);
    // }
    //vertex(width, height);
    //vertex(0, height);
    // endShape(CLOSE);
  }
}
