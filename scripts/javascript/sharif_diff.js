#!/usr/bin/env node

var fs = require('fs');
var a = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
var b = JSON.parse(fs.readFileSync(process.argv[3], 'utf8'));

const marked_courses = JSON.parse((process.env.marked_courses) || '[]').map(x => x.toString())
// console.log(JSON.stringify(marked_courses))

///
// > "" == 0
// true
// > 10 < ""
// false
// > 10 == ""
// false
// > 10 > ""
// true
///
for ( var i=0; i < b.length ; i++ ){
    bi = b[i]
    bid = bi.CourseID
    bn = bi.Name + " (group: " + bi.Group + ", id:" + bi.CourseID + ")"

    ai = null
    for (var at in a) {
        at = a[at]
        if (bid == at.CourseID && bi.Group == at.Group) {
            ai = at
        }
    }
    if (ai == null) {
        console.log("ƪ " + bn + " is new:\n" + JSON.stringify(bi, null, 4))
        continue
    }
}
for ( var i=0; i < a.length ; i++ ){
    ai = a[i]
    aid = ai.CourseID
    an = ai.Name + " (group: " + ai.Group + ", id:" + ai.CourseID + ")"

    bi = null
    for (var bt in b) {
        bt = b[bt] // js sucks
        // console.log("bt id: " + JSON.stringify(bt,null,4))
        if (aid == bt.CourseID && ai.Group == bt.Group) {
            bi = bt
        }
    }
    if (bi == null) {
        console.log("WARN: " + an + " has changed its ID or group or the course has been deleted. (Skipping it.)")
        continue
    }

    bid = bi.CourseID
    bn = bi.Name + " (group: " + bi.Group + ", id:" + bi.CourseID + ")"


    if (aid != bid) {
        console.log("WARN: " + an + "'s id has changed from " + aid + " to " + bid)
        continue
    }
    if (an != bn) {
        console.log("WARN: " + an + "'s name has changed to " + bn)
        continue
    }

    ac = parseInt(ai.Capacity) || Infinity
    bc = parseInt(bi.Capacity) || Infinity

    ae = parseInt(ai.EnrolledStudents) || 0
    be = parseInt(bi.EnrolledStudents) || 0

    if (bc > ac) {
        // "ƪ " forces LTR in Telegram
        console.log("ƪ " + an + "'s capacity increased from " + ac + " to " + bc + " (" + be + " students currently enrolled)")
    }

    if (be < ae && (marked_courses.includes(aid.toString()) || ac == ae)) {
        console.log("ƪ " + an + "'s enrolled students decreased from " + ae + " to " + be + " (current capacity: " + bc + ")")
    }

}