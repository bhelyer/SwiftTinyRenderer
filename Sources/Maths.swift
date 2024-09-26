func barycentric(_ pts: [Vec2i], _ p: Vec2i) -> Vec3r {
    let lx = Real(pts[2][0]-pts[0][0])
    let ly = Real(pts[1][0]-pts[0][0])
    let lz = Real(pts[0][0]-p[0])
    let l = Vec3r(x: lx, y: ly, z: lz)

    let rx = Real(pts[2][1]-pts[0][1])
    let ry = Real(pts[1][1]-pts[0][1])
    let rz = Real(pts[0][1]-p[1])
    let r = Vec3r(x: rx, y: ry, z: rz)

    let u = l ^ r

    // `pts` and `p` have integer value coordinates.
    // `abs(u[2]) < 1` means `u[2]` is 0, which means
    // the triangle is degenerate. Return something with negative coords.
    if abs(u.z) < 1 { return Vec3r(x: -1, y: -1, z: -1) }

    let x = 1.0 - (u.x + u.y) / u.z
    let y = u.y / u.z
    let z = u.x / u.z
    return Vec3r(x: x, y: y, z: z)
}