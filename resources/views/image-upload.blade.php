<!DOCTYPE html>
<html>
<head>
    <title>Laravel 10 Image Upload</title>
</head>
<body>
    <h2>Upload Image</h2>

    @if (session('success'))
        <p style="color: green;">{{ session('success') }}</p>
        <img src="{{ asset('storage/' . session('path')) }}" width="300" />
    @endif

    @if ($errors->any())
        <p style="color: red;">{{ $errors->first('image') }}</p>
    @endif

    <form action="{{ route('image.upload') }}" method="POST" enctype="multipart/form-data">
        @csrf
        <label>Select image:</label>
        <input type="file" name="image" required>
        <br><br>
        <button type="submit">Upload</button>
    </form>
</body>
</html>
