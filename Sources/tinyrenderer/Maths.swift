func barycentric(_ a: Vec3r, _ b: Vec3r, _ c: Vec3r, _ p: Vec3r) -> Vec3r {
    var s0 = Vec3r()
    var s1 = Vec3r()
    s1.x = c.y - a.y
    s1.y = b.y - a.y
    s1.z = a.y - p.y
    s0.x = c.x - a.x
    s0.y = b.x - a.x
    s0.z = a.x - p.x
    let u = s0 ^ s1
    if abs(u.z) > 1e-2 {
        return Vec3r(x: 1.0 - (u.x + u.y) / u.z, y: u.y / u.z, z: u.x / u.z)
    } else {
        return Vec3r(x: -1, y: 1, z: 1)
    }
}