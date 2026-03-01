package com.pavan.todo.services;

import java.util.List;

import com.pavan.todo.models.Todo;
import com.pavan.todo.repositories.TodoRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import io.micrometer.core.instrument.Counter;

@Service
public class TodoService {

    @Autowired
    TodoRepository todoRepository;

    private Counter todocounter;
    private MeterRegistry meterRegistry;

    public TodoService(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.todocounter = Counter.builder("todo_requests_total")
                .tags(...tags:"status", "created")
                .description("Total number of requests to the Todo API")
                .register(meterRegistry);
    }

    public List<Todo> findAll() {
        Sort sortByCreatedAtDesc = Sort.by(Sort.Direction.DESC, "createdAt");
        return todoRepository.findAll(sortByCreatedAtDesc);
    }

    public Todo createTodo(Todo todo) {
        todo.setCompleted(false);
        this.todocounter.increment();
        return todoRepository.save(todo);
    }

    public ResponseEntity<Todo> updateTodo(String id, Todo todo) {
        return todoRepository.findById(id).map(todoData -> {
            todoData.setTitle(todo.getTitle());
            todoData.setCompleted(todo.isCompleted());
            Todo updatedTodo = todoRepository.save(todoData);
            return ResponseEntity.ok().body(updatedTodo);
        }).orElse(ResponseEntity.notFound().build());
    }

    public ResponseEntity<?> deleteTodo(String id) {
        return todoRepository.findById(id).map(todo -> {
            todoRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }

    private void recordPendingItems() {
        long pendingItems = todoRepository.countByCompleted(false);
        meterRegistry.gauge(name: "pending_todo_items", pendingItems);
    }
}
