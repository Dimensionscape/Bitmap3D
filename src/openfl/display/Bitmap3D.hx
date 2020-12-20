package openfl.display;
import openfl.display.Sprite;
import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Graphics;
import openfl.display.TriangleCulling;
import openfl.geom.*;
import openfl.Vector;
import openfl.events.Event;
/**
 * ...
 * @author Christopher Speciale, Dimensionscape LLC
 */
class Bitmap3D extends Sprite
{
	private var __matrix3D:Matrix3D = new Matrix3D();
	private var __vertices:Vector<Float> = new Vector<Float>();
	private var __uvtData:Vector<Float>=Vector.ofArray([0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0]);
	private var __indices:Vector<Int> = Vector.ofArray([0, 1, 3, 1, 2, 3]);
	private var __points:Vector<Float>;
	private var __perspective:PerspectiveProjection = new PerspectiveProjection();
	private var __projectionMatrix:Matrix3D;
	private var __bitmapData:BitmapData;
	private var __pivotVec:Vector3D = new Vector3D();
	
	public var rotationX(default, set):Float = 0;
	public var rotationY(default, set):Float = 0;
	public var rotationZ(default, set):Float = 0;
	public var rotationPX(default, set):Float = 0;
	public var rotationPY(default, set):Float = 0;
	public var rotationPZ(default, set):Float = 0;
	
	public var offsetX(default, set):Float = 0;
	public var offsetY(default, set):Float = 0;
	public var offsetZ(default, set):Float = 0;
	
	public var pivotX(default, set):Float = 0; 
	public var pivotY(default, set):Float = 0; 
	public var pivotZ(default, set):Float = 0; 
	
	@:isVar public var fieldOfView(get, set) :Float = 0; 
	@:isVar public var focalLength(get, set):Float = 0; 
	
	public var triangleCulling:TriangleCulling = TriangleCulling.NONE;
	
	private var __bitmapHeight:Float;
	private var __bitmapWidth:Float;
	private var __bitmapX:Float;
	private var __bitmapY:Float;
	
	public var smoothing:Bool;
	
	override private function set_width(width:Float):Float{
		__bitmapWidth = width;
		__updateVertices();
		if (parent != null)
		{
			__updateGraphics();
		}
		return width;
	}
	
	override private function set_height(height:Float):Float{
		__bitmapHeight = height;
		__updateVertices();
		if (parent != null)
		{
			__updateGraphics();
		}
		return height;
	}
	
	override private function get_width():Float{
		return __bitmapWidth;
	}
	
	override private function get_height():Float{
		return __bitmapHeight;
	}
	
	override private function get_x():Float{
		return __bitmapX;
	}
	
	override private function get_y():Float{
		return __bitmapY;
	}	
	
	public function set_fieldOfView(value:Float):Float
	{
		__perspective.fieldOfView = value;
		__updatePerspective();
		return value;
	}
	
	public function set_focalLength(value:Float):Float
	{
		__perspective.focalLength = value;
		__updatePerspective();
		return value;
	}
	
	public function get_fieldOfView():Float{
		return __perspective.fieldOfView;
	}
	
	public function get_focalLength():Float{
		return __perspective.focalLength;
	}
	
	public function set_pivotX(x:Float):Float
	{
		__pivotVec.x = x;
		return pivotX;
	}
	
	public function set_pivotY(y:Float):Float
	{
		__pivotVec.y = y;
		return pivotY;
	}
	
	public function set_pivotZ(z:Float):Float
	{
		__pivotVec.z = z;
		return pivotZ;
	}
	
	public function set_offsetX(value:Float):Float
	{
		return offsetX = value;
		
	}
	
	public function set_offsetY(value:Float):Float
	{
		return offsetY = value;
		
	}
	
	public function set_offsetZ(value:Float):Float
	{
		return offsetZ = value;
		
	}
	
	public function set_rotationX(angle:Float):Float
	{
		rotationX = angle;
		__updateGraphics();
		return angle;
	}

	public function set_rotationY(angle:Float):Float
	{
		rotationY = angle;
		__updateGraphics();
		return angle;
	}

	public function set_rotationZ(angle:Float):Float
	{
		rotationZ = angle;
		__updateGraphics();
		return angle;
	}

	public function set_rotationPX(angle:Float):Float
	{
		rotationPX = angle;
		__updateGraphics();
		return angle;
	}

	public function set_rotationPY(angle:Float):Float
	{
		rotationPY = angle;
		__updateGraphics();
		return angle;
	}
	
	public function set_rotationPZ(angle:Float):Float
	{
		rotationPZ = angle;
		__updateGraphics();
		return angle;
	}

	public function new(bitmapData:BitmapData, smoothing:Bool = false)
	{
		super();
		this.smoothing = smoothing;
		__bitmapData = bitmapData;
		__bitmapWidth = __bitmapData.width;
		__bitmapHeight = __bitmapData.height;
		__updateVertices();		
		addEventListener(Event.ADDED_TO_STAGE, __onInit);
	}

	private function __onInit(e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, __onInit);

		//fieldOfView = 45;
		__updatePerspective();
	}
	
	private function __updateVertices():Void{
		__vertices = new Vector();
		//0
		__vertices.push(this.x);
		__vertices.push(this.y);
		__vertices.push(0);
		//1		
		__vertices.push(__bitmapWidth);
		__vertices.push(y);
		__vertices.push(0);
		//2
		__vertices.push(__bitmapWidth);
		__vertices.push(__bitmapHeight);
		__vertices.push(0);
		//3
		__vertices.push(x);
		__vertices.push(__bitmapHeight);
		__vertices.push(0);	
	}
	
	private function __updatePerspective():Void{
	__projectionMatrix = __perspective.toMatrix3D();
		__updateGraphics();
	}

	private function __updateGraphics():Void
	{
		__matrix3D.identity();
		__matrix3D.prependRotation(rotationPX, Vector3D.X_AXIS);
		__matrix3D.prependRotation(rotationPY, Vector3D.Y_AXIS);
		__matrix3D.prependRotation(rotationPZ, Vector3D.Z_AXIS);
		__matrix3D.appendRotation(rotationX, Vector3D.X_AXIS, __pivotVec);
		__matrix3D.appendRotation(rotationY, Vector3D.Y_AXIS, __pivotVec);
		__matrix3D.appendRotation(rotationZ, Vector3D.Z_AXIS, __pivotVec);
		__matrix3D.appendTranslation(offsetX, offsetY, offsetZ);
		__matrix3D.append(__projectionMatrix);
		
		__points = new Vector<Float>();
		Utils3D.projectVectors(__matrix3D, __vertices, __points, __uvtData);
		this.graphics.clear();
		this.graphics.beginBitmapFill(__bitmapData, null, false, smoothing);
		this.graphics.drawTriangles(__points, __indices, __uvtData, triangleCulling);
		this.graphics.endFill();
	}

}
