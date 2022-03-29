"use strict";(self.webpackChunknature_2_d_docs=self.webpackChunknature_2_d_docs||[]).push([[876],{3905:function(e,t,n){n.d(t,{Zo:function(){return c},kt:function(){return h}});var i=n(7294);function o(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function r(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);t&&(i=i.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,i)}return n}function a(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?r(Object(n),!0).forEach((function(t){o(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):r(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function d(e,t){if(null==e)return{};var n,i,o=function(e,t){if(null==e)return{};var n,i,o={},r=Object.keys(e);for(i=0;i<r.length;i++)n=r[i],t.indexOf(n)>=0||(o[n]=e[n]);return o}(e,t);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);for(i=0;i<r.length;i++)n=r[i],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(o[n]=e[n])}return o}var l=i.createContext({}),s=function(e){var t=i.useContext(l),n=t;return e&&(n="function"==typeof e?e(t):a(a({},t),e)),n},c=function(e){var t=s(e.components);return i.createElement(l.Provider,{value:t},e.children)},u={inlineCode:"code",wrapper:function(e){var t=e.children;return i.createElement(i.Fragment,{},t)}},p=i.forwardRef((function(e,t){var n=e.components,o=e.mdxType,r=e.originalType,l=e.parentName,c=d(e,["components","mdxType","originalType","parentName"]),p=s(n),h=o,g=p["".concat(l,".").concat(h)]||p[h]||u[h]||r;return n?i.createElement(g,a(a({ref:t},c),{},{components:n})):i.createElement(g,a({ref:t},c))}));function h(e,t){var n=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var r=n.length,a=new Array(r);a[0]=p;var d={};for(var l in t)hasOwnProperty.call(t,l)&&(d[l]=t[l]);d.originalType=e,d.mdxType="string"==typeof e?e:o,a[1]=d;for(var s=2;s<r;s++)a[s]=n[s];return i.createElement.apply(null,a)}return i.createElement.apply(null,n)}p.displayName="MDXCreateElement"},800:function(e,t,n){n.r(t),n.d(t,{frontMatter:function(){return d},contentTitle:function(){return l},metadata:function(){return s},toc:function(){return c},default:function(){return p}});var i=n(7462),o=n(3366),r=(n(7294),n(3905)),a=["components"],d={sidebar_position:4},l="Operations on RigidBodies",s={unversionedId:"tutorial-basics/RigidBody Operations",id:"tutorial-basics/RigidBody Operations",isDocsHomePage:!1,title:"Operations on RigidBodies",description:"RigidBodies have many methods that can help create better simulations. Be sure to check out the RigidBody API.",source:"@site/docs/tutorial-basics/RigidBody Operations.md",sourceDirName:"tutorial-basics",slug:"/tutorial-basics/RigidBody Operations",permalink:"/Nature2D/docs/tutorial-basics/RigidBody Operations",editUrl:"https://github.com/jaipack17/Nature2D/edit/master/docs/docs/tutorial-basics/RigidBody Operations.md",tags:[],version:"current",sidebarPosition:4,frontMatter:{sidebar_position:4},sidebar:"tutorialSidebar",previous:{title:"Custom Physical Properties",permalink:"/Nature2D/docs/tutorial-basics/Custom Physical Properties"},next:{title:"Creating Custom Constraints",permalink:"/Nature2D/docs/tutorial-basics/Custom Constraints"}},c=[{value:"Anchoring and Unanchoring RigidBodies",id:"anchoring-and-unanchoring-rigidbodies",children:[],level:2},{value:"Rotating, Changing Position and Sizes of the RigidBodies",id:"rotating-changing-position-and-sizes-of-the-rigidbodies",children:[],level:2},{value:"Events",id:"events",children:[],level:2},{value:"Fetch Methods",id:"fetch-methods",children:[],level:2},{value:"Other",id:"other",children:[],level:2}],u={toc:c};function p(e){var t=e.components,n=(0,o.Z)(e,a);return(0,r.kt)("wrapper",(0,i.Z)({},u,n,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("h1",{id:"operations-on-rigidbodies"},"Operations on RigidBodies"),(0,r.kt)("p",null,"RigidBodies have many methods that can help create better simulations. Be sure to check out the ",(0,r.kt)("a",{parentName:"p",href:"https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody"},"RigidBody API"),"."),(0,r.kt)("hr",null),(0,r.kt)("p",null,"The ",(0,r.kt)("inlineCode",{parentName:"p"},'Engine:Create("RigidBody", propertyTable)')," method returns a rigidbody on creation which can be used to perform different actions upon."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local ReplicatedStorage = game:GetService("ReplicatedStorage")\nlocal Nature2D = require(ReplicatedStorage.Nature2D)\n\nlocal engine = Nature2D.init(screenGuiInstance)\n\nlocal newBody = engine:Create("RigidBody", { \n    Object = UIElement,\n    Collidable = true,\n    Anchored = false -- unanchored collidable rigid body.\n}) \n')),(0,r.kt)("hr",null),(0,r.kt)("h2",{id:"anchoring-and-unanchoring-rigidbodies"},"Anchoring and Unanchoring RigidBodies"),(0,r.kt)("p",null,"In order to anchor or unanchor rigid bodies, use the ",(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:Anchor()")," or ",(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:Unanchor()")," methods, or pass in ",(0,r.kt)("inlineCode",{parentName:"p"},"Anchored")," property as true when creating a rigid body."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'\nlocal newBody = engine:Create("RigidBody", { \n    Object = UIElement,\n    Collidable = true,\n    Anchored = true -- anchored collidable rigid body.\n})\n')),(0,r.kt)("p",null,"Using methods:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"newBody:Anchor()\n")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"newBody:Unanchor()\n")),(0,r.kt)("h2",{id:"rotating-changing-position-and-sizes-of-the-rigidbodies"},"Rotating, Changing Position and Sizes of the RigidBodies"),(0,r.kt)("p",null,"In order to rotate, change positions and sizes of the RigidBody's UI element, use the ",(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:Rotate()"),", ",(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:SetPosition()")," and ",(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:SetSize()")," methods."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local newBody = engine:Create("RigidBody", { \n    Object = UIElement,\n    Collidable = true,\n    Anchored = true -- anchored collidable rigid body.\n})\nnewBody:Rotate(45) -- rotate by 45 degrees\nnewBody:SetPosition(Vector2.new(100, 100))\nnewBody:SetSize(Vector2.new(100, 150))\n')),(0,r.kt)("p",null,"You can create cool simulations like this one!"),(0,r.kt)("p",null,(0,r.kt)("img",{parentName:"p",src:"https://user-images.githubusercontent.com/74130881/137575974-bc4187f1-0dda-4ff7-aa5f-a9aa6a63743b.gif",alt:"ezgif com-gif-maker (17)"})),(0,r.kt)("h2",{id:"events"},"Events"),(0,r.kt)("p",null,"You can use events to perform tasks when something happens. There are 2 events for RigidBodies at present: ",(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody.Touched")," and ",(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody.CanvasEdgeTouched"),"."),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody.Touched")," is fired when the RigidBody collides with another RigidBody."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"newBody.Touched:Connect(function(otherRigidBodyID) -- id of the rigid body it touched\n    local other = engine:GetBodyById(otherRigidBodyID)\n    if other then\n       other:Destroy() -- destroy the rigid body that touched newBody\n    end\nend)\n")),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody.CanvasEdgeTouched")," is fired when the RigidBody touches any of the canvas' boundaries."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"newBody.CanvasEdgeTouched:Connect(function()\n    newBody:Destroy() -- destroy newBody if it touches the canvas' boundaries\nend)\n")),(0,r.kt)("h2",{id:"fetch-methods"},"Fetch Methods"),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:GetFrame()")," returns the UI element associated with the RigidBody"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"newBody:GetFrame().BackgroundColor3 = Color3.new(1, 0, 0)\n")),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:GetId()")," returns the unique ID for the rigidbody."),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:GetVertices()")," & ",(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:GetConstraints()")," return a table of 4 points and constraints associated with the RigidBody."),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:GetTouchingRigidBodies()")," - returns a table of RigidBodies in collision with the current."),(0,r.kt)("h2",{id:"other"},"Other"),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:KeepInCanvas()")," takes in 1 parameter which is a boolean, if false, it allows the rigid body to go past the canvas' boundaries."),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:CanCollide()")," takes in 1 parameter which is a boolean, if false, it won't collide with any other rigid body."),(0,r.kt)("p",null,(0,r.kt)("inlineCode",{parentName:"p"},"RigidBody:SetLifeSpan()")," takes in 1 parameter, which is time in seconds. The rigidbody is destroyed after the set amount of time is passed."),(0,r.kt)("p",null,(0,r.kt)("strong",{parentName:"p"},"Also check out other methods in the RigidBody API!")))}p.isMDXComponent=!0}}]);