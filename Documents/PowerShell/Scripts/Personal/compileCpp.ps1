function Compile_Run_Cc {
    param(
        [string]$SourceFile,
        [switch]$sanitize,
        [switch]$opencv
    )

    $CXX = 'g++'

    $CompilerOptions = "-std=c++20 -Wall -O3 -mtune=native -march=native -DDEBUG"

    if ($sanitize) {
        $CompilerOptions += ' -fsanitize=undefined -fsanitize-undefined-trap-on-error -D_GLIBCXX_DEBUG'
    }

    if ($opencv) {
        $CompilerOptions += ' -I C\\msys64\\mingw64\\include -lopencv_core452 -lopencv_imgcodecs452 -lopencv_imgproc452 -lopencv_calib3d452 -lopencv_dnn452 -lopencv_features2d452 -lopencv_flann452 -lopencv_gapi452 -lopencv_highgui452 -lopencv_ml452 -lopencv_objdetect452 -lopencv_photo452 -lopencv_stitching452 -lopencv_video452 -lopencv_videoio452'
    }

    $ExecutableName = $SourceFile.Replace('.\', '').Replace('.cpp', '')
    $Command = "$CXX $ExecutableName.cpp $CompilerOptions -o $ExecutableName"

    Write-Output "Compiling and running $ExecutableName.cpp with options: $CompilerOptions"
    Invoke-Expression $Command
    & ".\$ExecutableName"
}