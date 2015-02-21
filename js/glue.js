// Start Elm
presti = Elm.fullscreen(Elm.Presti, {
    'sliderValue': 50,
    'donePlaying': true
});

// Functions to play sound
var sound = (function(){
    var id = 0;
    var register_sound = function(newId){
        id = newId;
    }
    var get_sound_element = function(){
        return document.getElementById(id);
    }
    var object = {
        register_sound: register_sound,
        get_sound_element: get_sound_element
    };
    return object;
})();

function play_sound(bool){
    console.log('Got the value: ', bool);
    if(bool){
        var element = sound.get_sound_element()
        if (element != null) {
            element.play();
            presti.ports.donePlaying.send(true);
        }
    }
}

// Subscribe to playSound port
presti.ports.playSound.subscribe(play_sound);

// Subscribe to soundId port
presti.ports.soundId.subscribe(sound.register_sound);

// Start foundation
function refresh_foundation(x){
    $(document).foundation();
}

// Get slider value
function slider_value(){
    var val = int(document.getElementsByClassName(
        'range-slider')[0].getAttribute('data-slider'));
    console.log(val);
    presti.ports.sliderValue.send(val);
}

// Subscribe to refreshFoundation port
presti.ports.refreshFoundation.subscribe(refresh_foundation);

// Submit slider changes to Elm
$(document).foundation({
    slider: {
        on_change: function(){
            presti.ports.sliderValue.send(
                parseInt($('#slider').attr('data-slider')));
        }
    }
});
