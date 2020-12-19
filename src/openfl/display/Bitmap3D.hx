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
	private var __vertices:Vector<Float>=Vector.ofArray([-20, -20, 0, 20, -20, 0, 20, 20, 0, -20, 20, 0.0]);
	private var __uvtData:Vector<Float>=Vector.ofArray([0.0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0]);
	private var __indices:Vector<Int>=Vector.ofArray([0, 1, 3, 1, 2, 3]);
	private var __points:Vector<Float>;
	private var __perspective:PerspectiveProjection = new PerspectiveProjection();
	private var __projectionMatrix:Matrix3D;
	private var __bitmapData:BitmapData;
	private var __pivotVec:Vector3D = new Vector3D();

	public var rotationX(default, set):Float;
	public var rotationY(default, set):Float;
	public var rotationZ(default, set):Float;
	public var rotationPX(default, set):Float;
	public var rotationPY(default, set):Float;
	public var rotationPZ(default, set):Float;

	public var offsetX(default, set):Float;
	public var offsetY(default, set):Float;
	public var offsetZ(default, set):Float;

	public var pivotX(default, set):Float;
	public var pivotY(default, set):Float;
	public var pivotZ(default, set):Float;

	public var fieldOfView:Float;
	public var focalLength:Float;

	public function set_fieldOfView(value:Float):Float
	{
		__perspective.fieldOfView = value;
		return value;
	}

	public function set_focalLength(value:Float):Float
	{
		__perspective.focalLength = value;
		return value;
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
		__updateRotation();
		return angle;
	}

	public function set_rotationY(angle:Float):Float
	{
		rotationY = angle;
		__updateRotation();
		return angle;
	}

	public function set_rotationZ(angle:Float):Float
	{
		rotationZ = angle;
		__updateRotation();
		return angle;
	}

	public function set_rotationPX(angle:Float):Float
	{
		rotationPX = angle;
		__updateRotation();
		return angle;
	}

	public function set_rotationPY(angle:Float):Float
	{
		rotationPY = angle;
		__updateRotation();
		return angle;
	}

	public function set_rotationPZ(angle:Float):Float
	{
		rotationPZ = angle;
		__updateRotation();
		return angle;
	}

	public function new(bitmapData:BitmapData)
	{
		super();
		__bitmapData = bitmapData;
		addEventListener(Event.ADDED_TO_STAGE, __onInit);
	}

	private function __onInit(e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, __onInit);

		__points = new Vector<Float>(Math.ceil(__vertices.length / 3 * 2));
		fieldOfView = __perspective.fieldOfView = 45;
		__projectionMatrix = __perspective.toMatrix3D();
		__updateRotation();
	}

	private function __updateRotation():Void
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
		this.graphics.beginBitmapFill(__bitmapData, null, false, false);
		this.graphics.drawTriangles(__points, __indices, __uvtData, TriangleCulling.NONE);
		this.graphics.endFill();
	}

}
