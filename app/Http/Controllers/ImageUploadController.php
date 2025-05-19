<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ImageUploadController extends Controller
{
    public function showForm()
    {
        return view('image-upload');
    }

    public function upload(Request $request)
    {
        $request->validate([
            'image' => 'required|image|max:2048', // max 2MB
        ]);

        $path = $request->file('image')->store('uploads', 'public');

        return back()->with('success', 'Image uploaded successfully!')->with('path', $path);
    }
}
