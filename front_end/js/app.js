/**
 * 
 */

var App=angular.module("recipesPandora",["ngRoute"]);
App.factory('globalData', function() {
	 var displayingRecipe = false;
	 var recipes = [];
	 return {
		 getRecipes : function(){ return recipes; },
		 setRecipes : function(newRecipes){ recipes = newRecipes; },
	     getRecipe : function(){ return displayingRecipe; },
	     setRecipe : function(newRecipe){ displayingRecipe = newRecipe; }
	 };
});
App.config(function($routeProvider){
	$routeProvider
	.when('/',{
		templateUrl: 'template/list_recipes.html',
		controller: 'recipeListCtrl'
	})
	.when('/detail',{
		templateUrl: 'template/recipe_detail.html',
		controller: 'recipeDetailCtrl'
	})
	.otherwise({
		redirectTo: '/'
	})
});

App.controller("recipeListCtrl",function($scope,$location,$http, globalData){
		$scope.rawData = [];
		$scope.limit2Show = '10';
		$scope.recipeFilter= '';
		$scope.displayDetail=function(recipe){
			globalData.setRecipe(recipe);
			$location.path( '/detail' );
//			$scope.$parent.displayDetail(true);
		};
		var data = globalData.getRecipes();
		if(data.length <= 0){
			$http.get("http://recpandoraapi.webcindario.com/damejson.php")
			.then(function(response){
//			console.log(response);
				if(response.status==200){
					globalData.setRecipes(JSON.parse(response.data.split('<!--')[0]));
					$scope.rawData=globalData.getRecipes();
				}else{
					alert("Problema de comunicación para obener el listado de recetas");
				}
			});
		}else{
			$scope.rawData=globalData.getRecipes();
		}
	});
App.controller("recipeDetailCtrl",function($scope,$location,$http, globalData){
	$scope.recipe=globalData.getRecipe();
	if($scope.recipe===false) $location.path("/");
	$scope.returnToMain=function(){
		globalData.setRecipe(false);
		$location.path("/");
	}
});
App.directive("recipeNav",function(){
	var directive ={};
	directive.restrict = 'A';
	directive.templateUrl="template/nav_recipes.html";
	directive.controller = function($scope,$location, $route, $http, globalData){
		$scope.categories = {};
		$http.get("http://recpandoraapi.webcindario.com/damejson.php")
		.then(function(response){
//			console.log(response);
			if(response.status==200){
				var rawData=JSON.parse(response.data.split('<!--')[0]);
				for(var idx in rawData){
					if($scope.categories[rawData[idx].category] == undefined) $scope.categories[rawData[idx].category]=[];
					$scope.categories[rawData[idx].category].push(rawData[idx]);
				}
			}else{
				alert("Problema de comunicación para obener el listado de navegacion");
			}
		});
		$scope.displayDetail=function(recipe){
			globalData.setRecipe(recipe);
			if($location.url()!='/detail') $location.path( '/detail' );
			else $route.reload();
//			$scope.$parent.displayDetail(true);
		};
	};
	return directive;
	
});
/*
(function principal(){
	var regresa = {};
	regresa.rawData={};
	regresa.categories={};
	function ValidURL(str) {
		 var pattern = new RegExp('^(https?:\\/\\/)?'+ // protocol
				  '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.?)+[a-z]{2,}|'+ // domain name
				  '((\\d{1,3}\\.){3}\\d{1,3}))'+ // OR ip (v4) address
				  '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // port and path
				  '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string
				  '(\\#[-a-z\\d_]*)?$','i'); // fragment locator
				  return pattern.test(str);
		}
	$(document).on('click', '#regresaListado' ,function(){
		$("#recetaSeleccionada").addClass("hidden");
		$("#principal").removeClass("hidden");
	});
	var fillLabels = function(obj){
		$("[data-label=name]").text(obj.name);
		$("[data-label=description]").text(obj.short_description);
		$("[data-label=author]").html(obj.author);
		if(ValidURL(obj.source)) $("[data-label=author]").html($("[data-label=author]").html()+"<a href=\""+obj.source+"\" ><i class=\"glyphicon glyphicon-link\"> </i></a>");
		else $("[data-label=author]").html($("[data-label=author]").html()+"&lt;<i class=\"glyphicon glyphicon-book\"> </i> "+obj.source+"&gt;");
		$("[data-label=dificult]").html(obj.dificult);
		$("[data-label=portion]").html(obj.portion_size);
		$("[data-label=time]").html(obj.time_preparation);
		
		$("[data-label=tags]").html('<span class="label label-primary">'+obj.tags.split(",").join('</span>  <span class="label label-primary">')+'</span>');
		
		$("[data-label=preparation]").html(obj.preparacion.replace("\n","<br /><br />"));
		$("[data-label=rate]").removeClass();
		$("[data-label=rate]").addClass("rating");
		$("[data-label=rate]").addClass("r"+obj.rate);
		$("[data-label=imgFt]").text(obj.imgFt);
		$("[data-label=img]").attr("src",obj.imgUrl);
		
		$("[data-label=ingredients").html("");
		for(var idx  in obj.ingredientes){
			$("[data-label=ingredients").append("<li>"+obj.ingredientes[idx].cantidad_primaria+" "+
					obj.ingredientes[idx].nombre+" "+
					(obj.ingredientes[idx].cantidad_secundaria.length==""?"":("("+obj.ingredientes[idx].cantidad_secundaria+")"))+"</li>");
		}
	};
	$(document).on('click', 'article' ,function(){
		var id = $(this).attr("id").split("rec_")[1];
		fillLabels($.grep(App.rawData,function(val,idx){ return val.id==id;})[0]);

		$("#principal").addClass("hidden");
		$("#recetaSeleccionada").removeClass("hidden");
	});
	$(document).on('click', '[data-recid]' ,function(){
		var id = $(this).data("recid");
		fillLabels($.grep(App.rawData,function(val,idx){ return val.id==id;})[0]);
		$("#principal").addClass("hidden");
		$("#recetaSeleccionada").removeClass("hidden");
	});
	
	regresa.dibuja_nav=function(){
		for(var idx in App.rawData){
			$("#principal").append("<article id=\"rec_"+App.rawData[idx].id+"\"></article>");
			$("article#rec_"+App.rawData[idx].id).append('<div class="imagen"><figure><img src="'+App.rawData[idx].imgUrl+'" /><br /><figcation>'+App.rawData[idx].imgFt+'</figcaption></figure></div>');
			$("article#rec_"+App.rawData[idx].id).append('<div class="encabezado"><h3>'+App.rawData[idx].name.toUpperCase()+'<br /><small>'+App.rawData[idx].short_description+'</small><\h3></div>');
			$("article#rec_"+App.rawData[idx].id).append('<br style="clear:both;" />');
		}
		for(var idx in App.categories){
			$("#listado").append("<h5>"+idx+"</h5><ul data-sublistado='"+idx+"'></ul>");
			for(var i in App.categories[idx]){
				$("[data-sublistado=\""+idx+"\"]").append("<li><span class=\"btn btn-link\" data-recid=\""+App.categories[idx][i].id+"\">"+App.categories[idx][i].name+"</span></li>");
			}
			
		}
	};
	
	$.ajax("http://recpandoraapi.webcindario.com/damejson.php",
			{
				crossDomain: true, 
				method: 'GET',
				error:function(){alert("Error de recuperación"); console.log(arguments);},
				success:function(){ 
					App.rawData=JSON.parse(arguments[0].split('<!--')[0]);
					for(var idx in App.rawData){
						if(App.categories[App.rawData[idx].category] == undefined) App.categories[App.rawData[idx].category]=[];
						App.categories[App.rawData[idx].category].push({name:App.rawData[idx].name,id:App.rawData[idx].id});
					}
					$(window).trigger('listosDatos');
				}
			});
	
	return regresa;
});

$(window).on('listosDatos',function(){
	App.dibuja_nav();
});*/