module.exports = (grunt) ->
  # Project configuration.
  grunt.initConfig(
    coffee: 
      app: 
        expand: true,
        cwd: 'src/'
        src: '**/*.coffee', 
        dest: 'dist/'
        ext: '.js'
      vendor:
        expand: true,
        cwd: 'vendor/'
        src: '**/*.coffee', 
        dest: 'dist/'
        ext: '.js'        

    copy:
      vendor:
        files:
          [
            expand: true,
            cwd: 'vendor/'
            src: ['**/*.js', '**/*.css', '**/*.png'], 
            dest: 'dist/'
          ]

    watch:
      #COFFEE
      app_coffee:
        files: ['src/**/*.coffee']
        tasks: 'coffee:app'

      v_coffee:
        files: ['vendor/**/*.coffee']
        tasks: 'coffee:vendor'

      copy:
        files: ['vendor/**/*.js']
        tasks: 'copy'

  );

  #TODO move over all js files in src to the dir in dist
  #TODO compile haml assets to javascript
  #TODO compile sass assets to css
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.registerTask('build', ['coffee', 'copy']);