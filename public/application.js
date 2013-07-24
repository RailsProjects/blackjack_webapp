$(document).ready(function () {
  player_hits();
  player_stays();
  dealer_hit();
});

function player_hits() {  // when the page loads, wire up this, but second hit doesn't give template
  //$("form#hit_form input").click(function() {

  // This gives template when player gets second hit
  $(document).on("click", "form#hit_form input", function() {
    // continuously look for element selector and alert
    // .on takes 3 params: "click" is event, "" is element, "" is anonymous function
    alert("player hits!");
    $.ajax({
      type: "POST",
      url: "/game/player/hit"
    }).done(function(msg) {   //chain method .done w/ anonymous func
      $("#game").replaceWith(msg) // replace div  w/ new returned contents
  });

    return false;
  });
}

function player_stays() {  // when the page loads, wire up this, but second hit doesn't give template
  //$("form#hit_form input").click(function() {

  // This gives template when player gets second hit
  $(document).on("click", "form#stay_form input", function() {
    // continuously look for element selector and alert
    // .on takes 3 params: "click" is event, "" is element, "" is anonymous function
    alert("player stays!");
    $.ajax({
      type: "POST",
      url: "/game/player/stay"
    }).done(function(msg) {   //chain method .done w/ anonymous func
      $("#game").replaceWith(msg) // replace div  w/ new returned contents
  });

    return false;
  });
}

function dealer_hit() {  // when the page loads, wire up this, but second hit doesn't give template
  //$("form#hit_form input").click(function() {

  // This gives template when player gets second hit
  $(document).on("click", "form#dealer_hit", function() {
    // continuously look for element selector and alert
    // .on takes 3 params: "click" is event, "" is element, "" is anonymous function
    alert("dealer hits!");
    $.ajax({
      type: "POST",
      url: "/game/dealer/hit"
    }).done(function(msg) {   //chain method .done w/ anonymous func
      $("#game").replaceWith(msg) // replace div  w/ new returned contents
  });

    return false;
  });
}
