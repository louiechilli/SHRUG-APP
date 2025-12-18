<template>
    <!-- Desktop Layout -->
    <section class="hidden lg:flex min-h-screen bg-gradient-to-b from-blue-900 via-purple-800 to-rose-500 text-white relative overflow-hidden">
    
        <!-- Background pattern -->
        <div class="background-pattern"></div>
        
        <!-- Content -->
        <slot />

    </section>
</template>

<style scoped>
    .background-pattern {
      opacity: 0.04;
      background-image: radial-gradient(circle at center center, #444cf7, #e5e5f7), repeating-radial-gradient(circle at center center, #444cf7, #444cf7, 10px, transparent 20px, transparent 10px);
      background-blend-mode: multiply;
      width: 100vw;
      height: 100vh;
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      z-index: 0;
    }
</style>