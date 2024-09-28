public func barycentric(_ pts: [Vec3r], _ p: Vec3r) -> Vec3r {
    let lx = pts[2].x - pts[0].x
    let ly = pts[1].x - pts[0].x
    let lz = pts[0].x - p.x
    let l = Vec3r(x: lx, y: ly, z: lz)

    let rx = pts[2].y - pts[0].y
    let ry = pts[1].y - pts[0].y
    let rz = pts[0].y - p.y
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