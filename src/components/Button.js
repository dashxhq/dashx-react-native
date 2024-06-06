import React from 'react';
import { TouchableOpacity, Text } from 'react-native';
import { createVariants } from 'class-variance-authority';
import { useTheme } from '../theme/ThemeContext';
import '../styles/output.css';

const buttonVariants = createVariants({
  base: 'px-4 py-2 rounded',
  variants: {
    primary: 'bg-primary text-white',
    secondary: 'bg-secondary text-white',
    accent: 'bg-accent text-white',
  },
  defaultVariants: {
    variant: 'primary',
  },
});

const Button = ({ variant = 'primary', label, onPress }) => {
  const { theme } = useTheme();
  const classes = buttonVariants({ variant });

  return (
    <TouchableOpacity className={`${classes} theme-${theme}`} onPress={onPress}>
      <Text className="text-center">{label}</Text>
    </TouchableOpacity>
  );
};

export default Button;
