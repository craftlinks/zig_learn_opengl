const std = @import("std");
const gl = @import("./gl.zig");
const zm = @import("zmath");
const common = @import("common");
const Camera = @This();

const CameraMovement = enum {
    FORWARD,
    BACKWARD,
    LEFT,
    RIGHT,
};

// Default camera values
const YAW: f32 = -90.0;
const PITCH: f32 =  0.0;
const SPEED: f32 = 2.5;
const SENSITIVITY: f32 = 0.1;
const ZOOM: f32 = 45.0;

// Camera attributes
position: zm.F32x4 = zm.loadArr3(.{0.0, 0.0, 0.0}),
front: zm.F32x4 = zm.loadArr3(.{0.0, 0.0, -1.0}),
up: zm.F32x4 = undefined,
right: zm.F32x4 = undefined,
world_up: zm.F32x4 = zm.loadArr3(.{0.0, 1.0, 0.0}),

// euler Angles
yaw: f32 = YAW,
pitch: f32 = PITCH,
    
// camera options
movement_speed: f32 = SPEED,
mouse_sensitivity: f32 = SENSITIVITY,
zoom: f32 = ZOOM,


pub fn cameraV(position: ?zm.F32x4, up: ?zm.F32x4) Camera {

    return Camera{
        .position = if(position) position else zm.loadArr3(.{0.0, 0.0, 0.0}),
        .world_up = if(up) up else zm.loadArr3(.{0.0, 1.0, 0.0}),
        .right = zm.normalize3(zm.cross3(.front, .world_up)),  // normalize the vectors, because their length gets closer to 0 the more you look up or down which results in slower movement.
        .up    = zm.normalize3(zm.cross3(.right, .front)),
    };
}

// returns the view matrix calculated using Euler Angles and the LookAt Matrix
pub fn getViewMatrix(self: Camera) zm.Mat {
    return zm.lookAtRh(self.position, self.position + self.front, self.up);
}

// processes input received from any keyboard-like input system. Accepts input parameter in the form of camera defined ENUM (to abstract it from windowing systems)
pub fn processKeyboard(self: Camera, direction: Camera.CameraMovement, delta_time: f32) void {
    const velocity = self.movement_speed * delta_time;
     switch (direction) {   
        .FORWARD => self.position += self.front * velocity,
        .BACKWARD => self.position -= self.front * velocity,
        .LEFT => self.position -= self.right * velocity,
        .RIGHT => self.position += self.right * velocity,
    }
}

// processes input received from a mouse input system. Expects the offset value in both the x and y direction.
pub fn processMouseMovement(self: Camera, xoffset: f32, yoffset: f32, constrain_pitch: bool) void {
    xoffset *= self.mouse_sensitivity;
    yoffset *= self.mouse_sensitivity;

    self.yaw += xoffset;
    self.pitch += yoffset;

    // make sure that when pitch is out of bounds, screen doesn't get flipped
    if (constrain_pitch) {
        if (self.pitch > 89.0)
            self.pitch = 89.0;
        if (self.pitch < -89.0)
            self.pitch = -89.0;
    }

    // update Front, Right and Up Vectors using the updated Euler angles
    updateCameraVectors();
}

// processes input received from a mouse scroll-wheel event. Only requires input on the vertical wheel-axis
pub fn processMouseScroll(self: Camera, yoffset: f32) void {
    self.zoom -= yoffset;
    if (self.zoom < 1.0)
        self.zoom = 1.0;
    if (self.zoom > 45.0)
        self.zoom = 45.0;
}

// calculates the front vector from the Camera's (updated) Euler Angles
fn updateCameraVectors(self: Camera) void {
    // calculate the new Front vector
    var front: zm.F32x4 = undefined;
    front[0] = @cos(self.yaw * common.RAD_CONVERSION) * @cos(self.pitch * common.RAD_CONVERSION);
    front[1] = @sin(self.pitch * common.RAD_CONVERSION);
    front[2] = @sin(self.yaw * common.RAD_CONVERSION) * @cos(self.pitch * common.RAD_CONVERSION);
    self.front = front;
    // also re-calculate the Right and Up vector
    self.right = zm.normalize3(zm.cross3(self.front, self.world_up));  // normalize the vectors, because their length gets closer to 0 the more you look up or down which results in slower movement.
    self.up    = zm.normalize3(zm.cross3(self.right, self.front));
}








