package com.pavan.todo.controllers;

import java.util.List;
import java.util.Random;

import javax.validation.Valid;

import com.pavan.todo.models.Todo;
import com.pavan.todo.services.TodoService;

import io.micrometer.core.annotation.Timed;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/todos")
@CrossOrigin
public class TodoController {

    @Autowired
    TodoService todoService;

    @Timed(value = "todo.getAll.time", description = "Time taken to return all todos", histogram = true)
    @GetMapping
    public List<Todo> getAllTodos() {
        return todoService.findAll();
    }

    @Timed(value = "todo.create.time", description = "Time taken to create a todo", histogram = true)
    @PostMapping
    public Todo createTodo(@Valid @RequestBody Todo todo) {
        return todoService.createTodo(todo);
    }

    @Timed(value = "todo.update.time", description = "Time taken to update a todo", histogram = true)
    @PutMapping("/{id}")
    public ResponseEntity<Todo> updateTodo(@PathVariable("id") String id, @Valid @RequestBody Todo todo) {
        return todoService.updateTodo(id, todo);
    }

    @Timed(value = "todo.delete.time", description = "Time taken to delete a todo", histogram = true)
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTodo(@PathVariable("id") String id) {
        return todoService.deleteTodo(id);
    }

    @Timed(value = "slow.request", description = "Slow API Response Time", histogram = true, percentiles = {0.5, 0.95, 0.99})
    @GetMapping("/slow")
    public String slowAPI(@RequestParam(value = "delay", defaultValue = "0") int delay)
            throws InterruptedException {
        if (delay == 0) {
            Random random = new Random();
            delay = random.nextInt(10);
        }
        Thread.sleep(delay * 1000L);
        return "Slow response with delay of " + delay + " seconds";
    }

}