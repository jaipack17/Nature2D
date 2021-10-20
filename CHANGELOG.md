# Releases

## v0.0.4 - Engine:SetSimulationSpeed() & Documentation

* Updated API-References for RigidBodies, Constraints, Points and Engine in response to this and previous updates.
* Documented source code with comments.
* Better error handling and error messages
* Added new Methods to Engine
   * `Engine:SetSimulationSpeed()`

## v0.0.3 - Frame-rate Independent!

**Earlier:** Simulations running on different frame rates had a difference in their speeds. A simulation running on 60fps would run faster than that of a simulation running at 30fps.

**Now:** Frame-rate no longer affects simulations. A RigidBody covering a distance of 10 units in a simulation running at 30fps and a simulation running 60fps will take almost the same time to reach the destination. 

## v0.0.2 - Custom Point Support, Configuration Methods and More!

* Installation through Wally! Nature2D can now be installed using [Wally](https://github.com/UpliftGames/wally), the package manager for Roblox. This requires wally to be installed on your device. In order to install Nature2D, add a dependency to your `wally.toml` file
   * ![dependency](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/3/4/8/348c3d6c9436a92cf44160b9e8aee5b2a5933193.png)

   * After you have added the dependency, run `wally install` in the command line. A "Packages" directory is created containing the library. You can now use Nature2D in your external editor using wally!

* Bug Fixes 
  * Linked Issue: [#1](https://github.com/jaipack17/Nature2D/issues/1)  
* `Engine:CreateCanvas()` now has an optional 'frame' parameter to help render custom points and constraints.
* Refactored certain segments of code for better readability. 
* Added Custom Point support to Engine
  * `Engine:CreatePoint()`
  * `Engine:GetPoints()` 
* Added new Configuration methods to Constraints
   * `Constraint:Stroke()` 
* Added new Configuration methods to Points
   * `Point:SetRadius()`
   * `Point:Stroke()`
   * `Point:Snap()`

## v0.0.1 - Improvements & New Methods

* Improved architecture for anchored RigidBodies.
* Constraints now have their own unique IDs like RigidBodies.
* Added new Methods to Constraints
   * `Constraint:GetLength()` 
   * `Constraint:Destroy()`
* Added new Methods to Engine
   * `Engine:GetConstraints()`
   * `Engine:GetConstraintById()`
* Added new Methods to RigidBodies
   * `RigidBody:SetFriction()`
   * `RigidBody:SetGravity()`