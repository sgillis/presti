#! /bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo """
// Start Elm
presti = Elm.fullscreen(Elm.Presti, {
    'sliderValue': 50,
    'donePlaying': true,
    'modelSent': false,
    'submitError': false,
    'currentTime': new Date().getTime() / 1000,
    'setModel': {
        'startDate': 0,
        'now': 0,
        'screen': 'QuestionScreen',
        'username': '',
        'password': '',
        'submit': false,
        'submitE': false,
        'submitted': false,
        'subject': {
            'number': ''
        },
        'experiment': {
            'i': 0,
            'rates': [50],
            'samples': [1],
            'sound': {
                'playSound': true,
                'soundId': 1
            }
        },
        'instructions': {
            'slider': 50,
            'sound': {
                'playSound': true,
                'soundId': 1
            }
        },
        'questions': {
            'errors': {
                'geslacht': false,
                'leeftijd': false,
                'vraag1': false,
                'vraag2': false,
                'vraag3': false,
                'vraag4': false,
                'vraag5': false,
                'vraag6': false,
                'vraag7': false,
                'vraag8': false,
                'vraag9': false,
                'vraag10': false,
                'vraag11': false,
            },
            'geslacht': '',
            'leeftijd': '',
            'vraag1': '',
            'vraag2': '',
            'vraag3': '',
            'vraag4': '',
            'vraag5': '',
            'vraag6': '',
            'vraag7': '',
            'vraag8': '',
            'vraag9': '',
            'vraag10': '',
            'vraag11': '',
            'opmerking1': '',
            'opmerking2': '',
            'opmerking3': '',
            'opmerking4': '',
            'opmerking5': '',
            'opmerking6': '',
            'opmerking7': '',
            'opmerking8': '',
            'opmerking9': '',
            'opmerking10': '',
        }
    }
});

// Submit the current time every second
(function submitTime(){
    presti.ports.currentTime.send(new Date().getTime() / 1000);
    setTimeout(submitTime, 1000);
})();

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

function play_sound(){
    var element = sound.get_sound_element();
    if (element != null) {
        element.play();
        presti.ports.donePlaying.send(true);
    }
}

function delay_play_sound(bool){
    // Dirty hack to make sure that we do not play the sound before the id is
    // updated
    if(bool){
        setTimeout(play_sound, 200);
    };
}

// Subscribe to playSound port
presti.ports.playSound.subscribe(delay_play_sound);

// Subscribe to soundId port
presti.ports.soundId.subscribe(sound.register_sound);

// Start foundation
function refresh_foundation(x){
    \$(document).foundation();
}

// Get slider value
function slider_value(){
    var val = int(document.getElementsByClassName(
        'range-slider')[0].getAttribute('data-slider'));
    presti.ports.sliderValue.send(val);
}

// Subscribe to refreshFoundation port
presti.ports.refreshFoundation.subscribe(refresh_foundation);

// Submit slider changes to Elm
\$(document).foundation({
    slider: {
        on_change: function(){
            presti.ports.sliderValue.send(
                parseInt(\$('#slider').attr('data-slider')));
        }
    }
});

// Model variable

var model = (function(){
    var elmModel = {};
    var justSent = false;
    var storedState = null;

    var get_sound_data_name = function(id){
        var audio = document.getElementById(id);
        var fullName = audio.getElementsByTagName('source')[0].src;
        return fullName.split('/').pop();
    };

    var create_ratings = function(rates){
        return rates.map(function(val, index, rs){
            return {
                'position': index+1,
                'rating': val,
                'sample': get_sound_data_name(index+1)
            }
        });
    };

    var create_post_string = function(){
        m = {
            'subject': {
                'number': elmModel.subject.number
            },
            'questions': {
                'question1': elmModel.questions.vraag1,
                'question2': elmModel.questions.vraag2,
                'question3': elmModel.questions.vraag3,
                'question4': elmModel.questions.vraag4,
                'question5': elmModel.questions.vraag5,
                'question6': elmModel.questions.vraag6,
                'question7': elmModel.questions.vraag7,
                'question8': elmModel.questions.vraag8,
                'question9': elmModel.questions.vraag9,
                'question10': elmModel.questions.vraag10,
                'question11': elmModel.questions.vraag11,
                'remark1': elmModel.questions.opmerking1,
                'remark2': elmModel.questions.opmerking2,
                'remark3': elmModel.questions.opmerking3,
                'remark4': elmModel.questions.opmerking4,
                'remark5': elmModel.questions.opmerking5,
                'remark6': elmModel.questions.opmerking6,
                'remark7': elmModel.questions.opmerking7,
                'remark8': elmModel.questions.opmerking8,
                'remark9': elmModel.questions.opmerking9,
                'remark10': elmModel.questions.opmerking10,
                'age': parseInt(elmModel.questions.leeftijd),
                'sex': elmModel.questions.geslacht
            },
            'authentication': {
                'username': elmModel.username,
                'password': elmModel.password
            },
            'ratings': create_ratings(elmModel.experiment.rates)
        }
        return JSON.stringify(m);
    };

    var update_model = function(new_model){
        elmModel = new_model;
        if(elmModel.submit == true && justSent == false){
            justSent = true
            x = new XMLHttpRequest();
            var url = '$BACKEND_URL';
            x.open('POST', url+'/experiment', true);
            x.setRequestHeader('Accept', 'application/json');
            x.onload = function(){
                console.log(this.responseText);
                if(this.responseText != '{\"success\":true}'){
                    presti.ports.submitError.send(true);
                };
                presti.ports.modelSent.send(true);
            }
            x.send(create_post_string())
            setTimeout(function(){ justSent = false; }, 2000);
        }

        if(elmModel.screen == 'SubjectScreen'){
            storedState = localStorage.getItem(
                'presti-'+elmModel.subject.number);
        } else if(elmModel.password == '') {
            console.log('Saving');
            localStorage.setItem('presti-'+elmModel.subject.number,
                JSON.stringify(elmModel));
        }

        if (elmModel.screen != 'SubjectScreen' && storedState != null) {
            console.log('Loading');
            m = JSON.parse(storedState)
            presti.ports.setModel.send(m);
            storedState = null;
        }
    };

    return {
        'update_model': update_model,
        'create_post_string': create_post_string,
        'get_elm_model': function(){ return elmModel; }
    };
})();

presti.ports.elmModel.subscribe(model.update_model);
""" > $DIR"/glue.js"
