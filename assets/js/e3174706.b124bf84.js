"use strict";(self.webpackChunknature_2_d_docs=self.webpackChunknature_2_d_docs||[]).push([[938],{3905:function(e,t,n){n.d(t,{Zo:function(){return u},kt:function(){return m}});var r=n(7294);function i(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function o(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function a(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?o(Object(n),!0).forEach((function(t){i(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):o(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function s(e,t){if(null==e)return{};var n,r,i=function(e,t){if(null==e)return{};var n,r,i={},o=Object.keys(e);for(r=0;r<o.length;r++)n=o[r],t.indexOf(n)>=0||(i[n]=e[n]);return i}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(r=0;r<o.length;r++)n=o[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(i[n]=e[n])}return i}var c=r.createContext({}),l=function(e){var t=r.useContext(c),n=t;return e&&(n="function"==typeof e?e(t):a(a({},t),e)),n},u=function(e){var t=l(e.components);return r.createElement(c.Provider,{value:t},e.children)},p={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},d=r.forwardRef((function(e,t){var n=e.components,i=e.mdxType,o=e.originalType,c=e.parentName,u=s(e,["components","mdxType","originalType","parentName"]),d=l(n),m=i,f=d["".concat(c,".").concat(m)]||d[m]||p[m]||o;return n?r.createElement(f,a(a({ref:t},u),{},{components:n})):r.createElement(f,a({ref:t},u))}));function m(e,t){var n=arguments,i=t&&t.mdxType;if("string"==typeof e||i){var o=n.length,a=new Array(o);a[0]=d;var s={};for(var c in t)hasOwnProperty.call(t,c)&&(s[c]=t[c]);s.originalType=e,s.mdxType="string"==typeof e?e:i,a[1]=s;for(var l=2;l<o;l++)a[l]=n[l];return r.createElement.apply(null,a)}return r.createElement.apply(null,n)}d.displayName="MDXCreateElement"},5557:function(e,t,n){n.r(t),n.d(t,{frontMatter:function(){return s},contentTitle:function(){return c},metadata:function(){return l},toc:function(){return u},default:function(){return d}});var r=n(7462),i=n(3366),o=(n(7294),n(3905)),a=["components"],s={sidebar_position:11},c=void 0,l={unversionedId:"tutorial-basics/Engine Iterations",id:"tutorial-basics/Engine Iterations",isDocsHomePage:!1,title:"Engine Iterations",description:"Iterations provide accurate calculations for more rigid and smoother physics. Constraint iterations are applied to Constraint:Constrain() method. Constraint iterations are extremely useful of rod constraints and rope constraints. Constraint iterations do not work on spring constraints.",source:"@site/docs/tutorial-basics/Engine Iterations.md",sourceDirName:"tutorial-basics",slug:"/tutorial-basics/Engine Iterations",permalink:"/Nature2D/docs/tutorial-basics/Engine Iterations",editUrl:"https://github.com/jaipack17/Nature2D/edit/master/docs/docs/tutorial-basics/Engine Iterations.md",tags:[],version:"current",sidebarPosition:11,frontMatter:{sidebar_position:11},sidebar:"tutorialSidebar",previous:{title:"Using Nature2D Plugins",permalink:"/Nature2D/docs/tutorial-basics/Using Nature2D Plugins"},next:{title:"Engine",permalink:"/Nature2D/docs/api/Engine"}},u=[],p={toc:u};function d(e){var t=e.components,n=(0,i.Z)(e,a);return(0,o.kt)("wrapper",(0,r.Z)({},p,n,{components:t,mdxType:"MDXLayout"}),(0,o.kt)("p",null,"Iterations provide accurate calculations for more rigid and smoother physics. Constraint iterations are applied to Constraint:Constrain() method. Constraint iterations are extremely useful of rod constraints and rope constraints. Constraint iterations do not work on spring constraints."),(0,o.kt)("p",null,"Collision iterations are used to provide accurate and rigid collision detection and resolution. By default both of these iterations are set to 1. Iterations can be in the range of 1-10 only. Collision iterations can be set only if quadtrees are being used in collision detection."),(0,o.kt)("p",null,"Keep in mind that the higher the number of iterations the more accurate results. But, having more iterations means you\u2019ll have to sacrifice performance. The lesser the number of iterations, the better performance but we\u2019ll have to sacrifice on accuracy. So be careful where you use them!"),(0,o.kt)("p",null,"You can set constraint iterations and collision iterations by using ",(0,o.kt)("inlineCode",{parentName:"p"},"Engine:SetConstraintIterations()")," and ",(0,o.kt)("inlineCode",{parentName:"p"},"Engine:SetCollisionIterations()"),"."),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-lua"},"local Engine = Nature2D.init(someScreenGuiInstance)\nEngine:UseQuadtrees(true)\nEngine:SetCollisionIterations(2)\nEngine:SetConstraintIterations(3)\n")),(0,o.kt)("div",{className:"admonition admonition-info alert alert--info"},(0,o.kt)("div",{parentName:"div",className:"admonition-heading"},(0,o.kt)("h5",{parentName:"div"},(0,o.kt)("span",{parentName:"h5",className:"admonition-icon"},(0,o.kt)("svg",{parentName:"span",xmlns:"http://www.w3.org/2000/svg",width:"14",height:"16",viewBox:"0 0 14 16"},(0,o.kt)("path",{parentName:"svg",fillRule:"evenodd",d:"M7 2.3c3.14 0 5.7 2.56 5.7 5.7s-2.56 5.7-5.7 5.7A5.71 5.71 0 0 1 1.3 8c0-3.14 2.56-5.7 5.7-5.7zM7 1C3.14 1 0 4.14 0 8s3.14 7 7 7 7-3.14 7-7-3.14-7-7-7zm1 3H6v5h2V4zm0 6H6v2h2v-2z"}))),(0,o.kt)("strong",{parentName:"h5"},"Recommended Iteration Amounts"))),(0,o.kt)("div",{parentName:"div",className:"admonition-content"},(0,o.kt)("p",{parentName:"div"},"Constraint Iterations - 3",(0,o.kt)("br",null),"\nCollision Iterations - 4"))))}d.isMDXComponent=!0}}]);